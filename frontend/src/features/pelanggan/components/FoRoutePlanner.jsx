import { useEffect, useMemo, useState } from "react";
import {
  GeoJSON,
  MapContainer,
  Marker,
  TileLayer,
  useMap,
  useMapEvents,
} from "react-leaflet";
import L from "leaflet";
import "leaflet/dist/leaflet.css";
import "./FoRoutePlanner.css";

const DEFAULT_CENTER = [-5.147665, 119.432732];
const DEFAULT_ZOOM = 13;
const OSRM_PUBLIC_HOST = "https://router.project-osrm.org";
const OSRM_LOCAL_HOST =
  typeof import.meta.env.VITE_OSRM_HOST === "string" &&
  import.meta.env.VITE_OSRM_HOST.trim()
    ? import.meta.env.VITE_OSRM_HOST.trim().replace(/\/$/, "")
    : "http://localhost:5000";

const BASEMAP_OPTIONS = [
  {
    key: "dark",
    label: "Dark",
    url: "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
    attribution: '&copy; <a href="https://carto.com/">CartoDB</a>',
  },
  {
    key: "light",
    label: "Light",
    url: "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
    attribution: '&copy; <a href="https://carto.com/">CartoDB</a>',
  },
  {
    key: "osm",
    label: "OSM",
    url: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
    attribution:
      '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
  },
  {
    key: "satellite",
    label: "Satellite",
    url: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
    attribution: "Tiles &copy; Esri",
  },
];

function createGlowIcon(label, variant) {
  return L.divIcon({
    className: "",
    html: `
            <div class="fo-marker fo-marker--${variant}">
                <span class="fo-marker__pulse"></span>
                <span class="fo-marker__core">${label}</span>
            </div>
        `,
    iconSize: [28, 28],
    iconAnchor: [14, 14],
  });
}

const PROVIDER_ICON = createGlowIcon("A", "provider");
const CUSTOMER_ICON = createGlowIcon("B", "customer");
const WAYPOINT_ICON = createGlowIcon("W", "waypoint");

function formatDistance(distanceInMeters) {
  const value = Number(distanceInMeters ?? 0);
  if (!Number.isFinite(value) || value <= 0) {
    return "-";
  }

  return `${(value / 1000).toFixed(2)} km`;
}

function formatDuration(durationInSeconds) {
  const value = Number(durationInSeconds ?? 0);
  if (!Number.isFinite(value) || value <= 0) {
    return "-";
  }

  const totalMinutes = Math.round(value / 60);
  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;

  if (hours <= 0) {
    return `${minutes} menit`;
  }

  return `${hours} jam ${minutes} menit`;
}

function haversineDistance(pointA, pointB) {
  const toRadians = (value) => (value * Math.PI) / 180;
  const earthRadius = 6371000;
  const deltaLat = toRadians(pointB.lat - pointA.lat);
  const deltaLng = toRadians(pointB.lng - pointA.lng);
  const latitudeA = toRadians(pointA.lat);
  const latitudeB = toRadians(pointB.lat);

  const base =
    Math.sin(deltaLat / 2) ** 2 +
    Math.cos(latitudeA) * Math.cos(latitudeB) * Math.sin(deltaLng / 2) ** 2;

  return 2 * earthRadius * Math.atan2(Math.sqrt(base), Math.sqrt(1 - base));
}

function buildControlPointFeature(point, role, index) {
  return {
    type: "Feature",
    properties: {
      role,
      orderNumber: index + 1,
      label: point.label || role,
      lat: point.lat,
      lng: point.lng,
    },
    geometry: {
      type: "Point",
      coordinates: [point.lng, point.lat],
    },
  };
}

function createRouteGeoJson(geometryCoordinates, properties) {
  return {
    type: "FeatureCollection",
    features: [
      {
        type: "Feature",
        properties,
        geometry: {
          type: "LineString",
          coordinates: geometryCoordinates,
        },
      },
    ],
  };
}

function extractRoadSegments(legs) {
  return (Array.isArray(legs) ? legs : []).flatMap((leg, legIndex) => {
    const steps = Array.isArray(leg?.steps) ? leg.steps : [];
    return steps.map((step, index) => ({
      id: `${legIndex}-${index}-${step?.name ?? "road"}`,
      name: step?.name?.trim() || "Tanpa nama jalan",
      distance: Number(step?.distance ?? 0),
      duration: Number(step?.duration ?? 0),
      instruction: step?.maneuver?.modifier
        ? `Manuver ${step.maneuver.modifier}`
        : "Lanjut lurus",
    }));
  });
}

function buildPointLabel(point, index, total) {
  if (point?.label && String(point.label).trim()) {
    return String(point.label).trim();
  }

  if (index === 0) {
    return "Titik A / Provider";
  }

  if (index === total - 1) {
    return "Titik B / Pelanggan";
  }

  return `Waypoint Manual ${index}`;
}

function normalizePreviewPointRole(pointType, index, total) {
  if (pointType === "awal" || index === 0) {
    return "provider";
  }

  if (pointType === "tujuan" || index === total - 1) {
    return "customer";
  }

  return "waypoint";
}

function MapClickHandler({ onMapClick }) {
  useMapEvents({
    click(event) {
      onMapClick(event.latlng);
    },
  });

  return null;
}

function MapViewportController({ flyTarget, fitRouteKey, fitCoordinates }) {
  const map = useMap();

  useEffect(() => {
    if (!flyTarget) {
      return;
    }

    map.flyTo([flyTarget.lat, flyTarget.lng], flyTarget.zoom ?? 16, {
      duration: 1.2,
    });
  }, [flyTarget, map]);

  useEffect(() => {
    if (!Array.isArray(fitCoordinates) || fitCoordinates.length < 2) {
      return;
    }

    const bounds = L.latLngBounds(
      fitCoordinates.map(([lat, lng]) => [lat, lng]),
    );
    map.fitBounds(bounds, { padding: [36, 36] });
  }, [fitCoordinates, fitRouteKey, map]);

  return null;
}

function ToastStack({ toasts, onDismiss }) {
  return (
    <div className="absolute right-4 top-4 z-[500] flex w-[min(360px,calc(100%-2rem))] flex-col gap-2.5 md:right-8 md:top-8">
      {toasts.map((toast) => {
        const bgClasses =
          {
            info: "bg-blue-600",
            success: "bg-emerald-600",
            warning: "bg-amber-500",
            error: "bg-rose-600",
          }[toast.tone] || "bg-slate-800";

        return (
          <div
            key={toast.id}
            className={`flex items-start justify-between gap-3 rounded-xl p-4 text-white shadow-lg ${bgClasses}`}
            role="status"
          >
            <div>
              <p className="text-xs font-bold uppercase tracking-wider text-white/90">
                {toast.title}
              </p>
              <p className="mt-1 text-sm text-white/90 leading-snug">
                {toast.message}
              </p>
            </div>
            <button
              className="text-white/70 transition hover:text-white"
              onClick={() => onDismiss(toast.id)}
              type="button"
            >
              <span className="material-symbols-outlined text-sm">close</span>
            </button>
          </div>
        );
      })}
    </div>
  );
}

export default function FoRoutePlanner({
  onApplyPlannedRoute,
  disabled = false,
  mode = "full",
  previewPoints = [],
  onPreviewClick,
}) {
  const [basemap, setBasemap] = useState("dark");
  const [profile, setProfile] = useState("driving");
  const [placementMode, setPlacementMode] = useState("a");
  const [pointA, setPointA] = useState(null);
  const [pointB, setPointB] = useState(null);
  const [manualWaypoints, setManualWaypoints] = useState([]);
  const [customRouteMode, setCustomRouteMode] = useState(false);
  const [routeData, setRouteData] = useState(null);
  const [isCalculating, setIsCalculating] = useState(false);
  const [routeError, setRouteError] = useState("");
  const [toasts, setToasts] = useState([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [searchResults, setSearchResults] = useState([]);
  const [searchError, setSearchError] = useState("");
  const [isSearching, setIsSearching] = useState(false);
  const [flyTarget, setFlyTarget] = useState(null);
  const [manualInput, setManualInput] = useState({
    aLat: "",
    aLng: "",
    bLat: "",
    bLng: "",
    wLat: "",
    wLng: "",
  });

  const selectedBasemap =
    BASEMAP_OPTIONS.find((item) => item.key === basemap) ?? BASEMAP_OPTIONS[0];
  const isPreviewMode = mode === "preview";
  const previewControlPoints = useMemo(
    () =>
      (Array.isArray(previewPoints) ? previewPoints : []).map(
        (point, index, list) => ({
          ...point,
          role:
            point.role ??
            normalizePreviewPointRole(point.pointType, index, list.length),
        }),
      ),
    [previewPoints],
  );
  const previewRouteGeoJson = useMemo(() => {
    if (!isPreviewMode || previewControlPoints.length < 2) {
      return null;
    }

    return createRouteGeoJson(
      previewControlPoints.map((point) => [point.lng, point.lat]),
      {
        source: "tenant-route-preview",
        mode: "preview",
      },
    );
  }, [isPreviewMode, previewControlPoints]);
  const previewFitCoordinates = useMemo(
    () => previewControlPoints.map((point) => [point.lat, point.lng]),
    [previewControlPoints],
  );
  const controlPoints = useMemo(() => {
    const points = [];
    if (pointA) {
      points.push({ ...pointA, role: "provider" });
    }
    manualWaypoints.forEach((point) => {
      points.push({ ...point, role: "waypoint" });
    });
    if (pointB) {
      points.push({ ...pointB, role: "customer" });
    }
    return points;
  }, [manualWaypoints, pointA, pointB]);

  const routeSummary = useMemo(
    () => ({
      pointCount: controlPoints.length,
      distanceLabel: formatDistance(routeData?.distance ?? 0),
      durationLabel: formatDuration(routeData?.duration ?? 0),
      roadCount: Array.isArray(routeData?.roads) ? routeData.roads.length : 0,
      source: routeData?.source ?? "-",
    }),
    [controlPoints.length, routeData],
  );

  const showManualRoute =
    customRouteMode && manualWaypoints.length > 0 && pointA && pointB;

  const pushToast = (title, message, tone = "info") => {
    const toastId = `toast-${Date.now()}-${Math.random().toString(16).slice(2)}`;
    setToasts((previous) => [
      ...previous,
      { id: toastId, title, message, tone },
    ]);
    window.setTimeout(() => {
      setToasts((previous) => previous.filter((toast) => toast.id !== toastId));
    }, 3600);
  };

  const dismissToast = (toastId) => {
    setToasts((previous) => previous.filter((toast) => toast.id !== toastId));
  };

  useEffect(() => {
    if (showManualRoute) {
      const manualPoints = [pointA, ...manualWaypoints, pointB];
      const totalDistance = manualPoints.reduce((total, point, index) => {
        if (index === 0) {
          return total;
        }
        return total + haversineDistance(manualPoints[index - 1], point);
      }, 0);

      const coordinates = manualPoints.map((point) => [point.lng, point.lat]);
      const roads = manualPoints.slice(1).map((point, index) => ({
        id: `manual-${index}`,
        name: point.label?.trim() || `Segmen Manual ${index + 1}`,
        distance: haversineDistance(manualPoints[index], point),
        duration: 0,
        instruction: "Waypoint manual",
      }));

      setRouteData({
        mode: "manual",
        source: "custom-route",
        distance: totalDistance,
        duration: 0,
        geometryCoordinates: coordinates,
        geoJson: createRouteGeoJson(coordinates, {
          source: "custom-route",
          mode: "manual",
          distance: totalDistance,
        }),
        roads,
      });
      setRouteError("");
      return;
    }

    if (!pointA || !pointB) {
      setRouteData(null);
      setRouteError("");
      setIsCalculating(false);
      return;
    }

    const controller = new AbortController();
    const coordinates = [pointA, pointB]
      .map((point) => `${point.lng},${point.lat}`)
      .join(";");
    const routePath = `/route/v1/${profile}/${coordinates}?overview=full&geometries=geojson&steps=true`;

    const fetchRoute = async () => {
      setIsCalculating(true);
      setRouteError("");

      const hosts = [OSRM_LOCAL_HOST, OSRM_PUBLIC_HOST];
      let lastError = null;

      for (const [index, host] of hosts.entries()) {
        try {
          const response = await fetch(`${host}${routePath}`, {
            signal: controller.signal,
          });
          if (!response.ok) {
            throw new Error(`OSRM gagal merespons (${response.status}).`);
          }

          const result = await response.json();
          if (
            result.code !== "Ok" ||
            !Array.isArray(result.routes) ||
            result.routes.length === 0
          ) {
            throw new Error("Rute tidak ditemukan.");
          }

          const primaryRoute = result.routes[0];
          const geometryCoordinates = Array.isArray(
            primaryRoute?.geometry?.coordinates,
          )
            ? primaryRoute.geometry.coordinates
            : [];
          const roads = extractRoadSegments(primaryRoute?.legs);
          const source = index === 0 ? "osrm-local" : "osrm-public";

          if (index > 0) {
            pushToast(
              "Server OSRM Lokal Offline",
              "Planner beralih ke router publik untuk menghitung jalur.",
              "warning",
            );
          } else {
            pushToast(
              "Rute Berhasil Dihitung",
              "Jalur otomatis dari server OSRM lokal berhasil dirender.",
              "success",
            );
          }

          setRouteData({
            mode: "osrm",
            source,
            distance: Number(primaryRoute.distance ?? 0),
            duration: Number(primaryRoute.duration ?? 0),
            geometryCoordinates,
            geoJson: createRouteGeoJson(geometryCoordinates, {
              source,
              mode: "osrm",
              distance: Number(primaryRoute.distance ?? 0),
              duration: Number(primaryRoute.duration ?? 0),
              roads,
            }),
            roads,
          });
          setRouteError("");
          setIsCalculating(false);
          return;
        } catch (error) {
          if (error?.name === "AbortError") {
            return;
          }

          lastError = error;
        }
      }

      setRouteData(null);
      setRouteError(
        lastError instanceof Error
          ? lastError.message
          : "Gagal menghitung rute OSRM.",
      );
      pushToast(
        "Rute Gagal Dihitung",
        lastError instanceof Error
          ? lastError.message
          : "Server OSRM tidak tersedia.",
        "error",
      );
      setIsCalculating(false);
    };

    void fetchRoute();

    return () => controller.abort();
  }, [
    customRouteMode,
    manualWaypoints,
    pointA,
    pointB,
    profile,
    showManualRoute,
  ]);

  const mapFitCoordinates = useMemo(() => {
    if (!routeData?.geometryCoordinates) {
      return [];
    }

    return routeData.geometryCoordinates.map(([lng, lat]) => [lat, lng]);
  }, [routeData?.geometryCoordinates]);

  const plannerRoads = Array.isArray(routeData?.roads) ? routeData.roads : [];

  const assignPoint = (role, lat, lng, label) => {
    const nextPoint = {
      id: `${role}-${Date.now()}`,
      lat: Number(lat),
      lng: Number(lng),
      label: label ?? "",
    };

    if (role === "a") {
      setPointA(nextPoint);
      pushToast(
        "Titik A Diperbarui",
        "Koordinat provider/source berhasil ditetapkan.",
        "success",
      );
      return;
    }

    if (role === "b") {
      setPointB(nextPoint);
      pushToast(
        "Titik B Diperbarui",
        "Koordinat pelanggan/destination berhasil ditetapkan.",
        "success",
      );
      return;
    }

    setManualWaypoints((previous) => [...previous, nextPoint]);
    pushToast(
      "Waypoint Ditambahkan",
      "Titik manual masuk ke custom route.",
      "info",
    );
  };

  const handleMapClick = (latlng) => {
    if (disabled) {
      return;
    }

    if (placementMode === "a") {
      assignPoint("a", latlng.lat, latlng.lng, "Provider");
      return;
    }

    if (placementMode === "b") {
      assignPoint("b", latlng.lat, latlng.lng, "Pelanggan");
      return;
    }

    assignPoint("waypoint", latlng.lat, latlng.lng, "");
  };

  const handleSearch = async (event) => {
    event.preventDefault();
    const query = searchQuery.trim();
    if (!query) {
      setSearchResults([]);
      setSearchError("");
      return;
    }

    setIsSearching(true);
    setSearchError("");

    try {
      const params = new URLSearchParams({
        q: query,
        format: "jsonv2",
        limit: "8",
        addressdetails: "1",
      });
      const response = await fetch(
        `https://nominatim.openstreetmap.org/search?${params.toString()}`,
        {
          headers: {
            Accept: "application/json",
          },
        },
      );

      if (!response.ok) {
        throw new Error(`Nominatim gagal merespons (${response.status}).`);
      }

      const result = await response.json();
      const normalized = Array.isArray(result) ? result : [];
      setSearchResults(normalized);
      pushToast(
        "Pencarian Selesai",
        `${normalized.length} lokasi ditemukan.`,
        "success",
      );
    } catch (error) {
      setSearchResults([]);
      setSearchError(
        error instanceof Error ? error.message : "Gagal mencari lokasi.",
      );
      pushToast(
        "Pencarian Gagal",
        error instanceof Error ? error.message : "Nominatim tidak tersedia.",
        "error",
      );
    } finally {
      setIsSearching(false);
    }
  };

  const handlePickSearchResult = (result, role) => {
    const lat = Number(result?.lat);
    const lng = Number(result?.lon);
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
      return;
    }

    setFlyTarget({ lat, lng, zoom: 17 });
    assignPoint(role, lat, lng, result.display_name);
  };

  const handleWaypointLabelChange = (pointId, value) => {
    setManualWaypoints((previous) =>
      previous.map((point) =>
        point.id === pointId ? { ...point, label: value } : point,
      ),
    );
  };

  const handleWaypointMove = (pointId, direction) => {
    setManualWaypoints((previous) => {
      const index = previous.findIndex((point) => point.id === pointId);
      if (index < 0) {
        return previous;
      }

      const nextIndex = direction === "up" ? index - 1 : index + 1;
      if (nextIndex < 0 || nextIndex >= previous.length) {
        return previous;
      }

      const nextPoints = [...previous];
      const [target] = nextPoints.splice(index, 1);
      nextPoints.splice(nextIndex, 0, target);
      return nextPoints;
    });
  };

  const handleWaypointDelete = (pointId) => {
    setManualWaypoints((previous) =>
      previous.filter((point) => point.id !== pointId),
    );
  };

  const handleManualInputApply = (role) => {
    const latKey = role === "a" ? "aLat" : role === "b" ? "bLat" : "wLat";
    const lngKey = role === "a" ? "aLng" : role === "b" ? "bLng" : "wLng";
    const lat = Number(manualInput[latKey]);
    const lng = Number(manualInput[lngKey]);

    if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
      pushToast(
        "Koordinat Tidak Valid",
        "Masukkan lat/lng numerik yang valid.",
        "error",
      );
      return;
    }

    assignPoint(role, lat, lng, "");
    setFlyTarget({ lat, lng, zoom: 17 });
  };

  const handleMarkerDrag = (role, id, lat, lng) => {
    if (role === "provider") {
      setPointA((previous) =>
        previous ? { ...previous, lat, lng } : previous,
      );
      return;
    }

    if (role === "customer") {
      setPointB((previous) =>
        previous ? { ...previous, lat, lng } : previous,
      );
      return;
    }

    setManualWaypoints((previous) =>
      previous.map((point) =>
        point.id === id ? { ...point, lat, lng } : point,
      ),
    );
  };

  const handleResetPlanner = () => {
    setPointA(null);
    setPointB(null);
    setManualWaypoints([]);
    setRouteData(null);
    setRouteError("");
    setSearchResults([]);
    setSearchError("");
    setSearchQuery("");
    pushToast(
      "Planner Direset",
      "Semua titik dan hasil rute dibersihkan.",
      "info",
    );
  };

  const handleExportGeoJson = () => {
    if (
      !routeData?.geometryCoordinates ||
      routeData.geometryCoordinates.length < 2
    ) {
      pushToast(
        "Export Gagal",
        "Belum ada rute aktif untuk diekspor.",
        "error",
      );
      return;
    }

    const featureCollection = {
      type: "FeatureCollection",
      features: [
        {
          type: "Feature",
          properties: {
            source: routeData.source,
            mode: routeData.mode,
            distanceMeters: routeData.distance,
            durationSeconds: routeData.duration,
            roads: plannerRoads,
          },
          geometry: {
            type: "LineString",
            coordinates: routeData.geometryCoordinates,
          },
        },
        ...controlPoints.map((point, index) =>
          buildControlPointFeature(point, point.role, index),
        ),
      ],
    };

    const blob = new Blob([JSON.stringify(featureCollection, null, 2)], {
      type: "application/geo+json",
    });
    const link = document.createElement("a");
    link.href = URL.createObjectURL(blob);
    link.download = `fo-route-${Date.now()}.geojson`;
    link.click();
    URL.revokeObjectURL(link.href);
    pushToast(
      "GeoJSON Diekspor",
      "File rute aktif berhasil diunduh.",
      "success",
    );
  };

  const handleApplyPlanner = () => {
    if (!pointA || !pointB) {
      pushToast(
        "Titik Belum Lengkap",
        "Tentukan Titik A dan Titik B sebelum menerapkan draft.",
        "error",
      );
      return;
    }

    const draftPoints = controlPoints.map((point, index) => {
      const pointType =
        index === 0
          ? "awal"
          : index === controlPoints.length - 1
            ? "tujuan"
            : "transit";

      return {
        id: `planner-draft-${Date.now()}-${index}`,
        pathName: buildPointLabel(point, index, controlPoints.length),
        pointType,
        note: `${routeData?.mode === "manual" ? "Custom Route" : "OSRM Route"} • ${point.lat.toFixed(5)}, ${point.lng.toFixed(5)}`,
        orderNumber: index + 1,
      };
    });

    onApplyPlannedRoute(draftPoints, {
      profile,
      source: routeData?.source ?? "planner",
      mode: routeData?.mode ?? "manual",
      distance: routeData?.distance ?? 0,
      duration: routeData?.duration ?? 0,
      roads: plannerRoads,
    });
    pushToast(
      "Draft Jalur Diperbarui",
      "Hasil planner diterapkan ke draft jalur tenant.",
      "success",
    );
  };

  const routeMainStyle = {
    color: "#38bdf8",
    weight: 4,
    opacity: 0.92,
  };
  const routeGlowStyle = {
    color: "#0ea5e9",
    weight: 10,
    opacity: 0.22,
  };

  if (isPreviewMode) {
    return (
      <section className="rounded-2xl bg-surface-container-lowest p-6 shadow-sm border border-slate-200">
        <div className="mb-6 flex items-start justify-between gap-3">
          <div>
            <p className="text-xs font-black uppercase tracking-widest text-on-surface-variant/70">
              Preview Jalur
            </p>
            <h3 className="mt-1 text-xl font-bold text-on-surface">
              Peta Lintasan Tenant
            </h3>
            <p className="mt-1 text-sm text-on-surface-variant">
              Klik peta untuk membuka halaman planner lengkap.
            </p>
          </div>
          <span className="rounded-full bg-blue-100 px-3 py-1 text-xs font-bold text-blue-700">
            View Only
          </span>
        </div>

        <div className="grid grid-cols-1 gap-6 lg:grid-cols-5">
          {/* Left Column: Map Preview */}
          <div className="relative overflow-hidden rounded-2xl border border-slate-200 lg:col-span-3 h-[500px]">
            <button
              aria-label="Buka halaman planner jalur"
              className="absolute inset-0 z-[450] cursor-pointer bg-transparent"
              onClick={onPreviewClick}
              type="button"
            />
            <div className="relative z-10 h-full">
              <MapContainer
                center={DEFAULT_CENTER}
                className="h-full w-full bg-slate-100"
                scrollWheelZoom
                zoom={DEFAULT_ZOOM}
              >
                <TileLayer
                  attribution={selectedBasemap.attribution}
                  url={selectedBasemap.url}
                />
                <MapViewportController
                  fitCoordinates={previewFitCoordinates}
                  fitRouteKey={`preview-${previewControlPoints.length}`}
                  flyTarget={null}
                />
                {previewControlPoints.map((point) => {
                  const icon =
                    point.role === "provider"
                      ? PROVIDER_ICON
                      : point.role === "customer"
                        ? CUSTOMER_ICON
                        : WAYPOINT_ICON;

                  return (
                    <Marker
                      key={point.id ?? `${point.role}-${point.lat}-${point.lng}`}
                      icon={icon}
                      position={[point.lat, point.lng]}
                    />
                  );
                })}
                {previewRouteGeoJson && (
                  <>
                    <GeoJSON
                      data={previewRouteGeoJson}
                      style={() => routeGlowStyle}
                    />
                    <GeoJSON
                      data={previewRouteGeoJson}
                      style={() => routeMainStyle}
                    />
                  </>
                )}
              </MapContainer>
            </div>

            <div className="absolute bottom-4 left-4 z-[450] flex flex-wrap items-center gap-2">
              <span className="rounded-full bg-white/90 backdrop-blur-sm px-3 py-1.5 text-xs font-bold text-slate-700 shadow-sm border border-slate-200">
                Titik: {previewControlPoints.length}
              </span>
              <span className="rounded-full bg-white/90 backdrop-blur-sm px-3 py-1.5 text-xs font-bold text-slate-700 shadow-sm border border-slate-200">
                {previewRouteGeoJson ? "Jalur Aktif" : "Tanpa Koordinat"}
              </span>
            </div>
          </div>

          {/* Right Column: Insights */}
          <div className="flex flex-col lg:col-span-2">
            <div className="flex flex-col h-full rounded-2xl border border-slate-200 bg-slate-50/50 p-6">
              <p className="text-[10px] font-black uppercase tracking-widest text-slate-500">
                Insights
              </p>
              <h3 className="mt-1 text-xl font-bold text-slate-900">
                Glosarium Jenis Titik
              </h3>
              <p className="mt-2 text-sm text-slate-500 leading-relaxed">
                Legenda simbol yang digunakan pada peta lintasan fiber optik.
              </p>

              <div className="mt-8 space-y-6 flex-1">
                <div className="flex items-start gap-4">
                  <div className="mt-1 flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-blue-100 text-blue-600">
                    <span className="material-symbols-outlined text-2xl">
                      router
                    </span>
                  </div>
                  <div>
                    <h4 className="text-sm font-bold text-slate-900">
                      Titik Awal
                    </h4>
                    <p className="mt-0.5 text-sm text-slate-600">
                      Manhole Utama / ODP (Optical Distribution Point)
                    </p>
                  </div>
                </div>

                <div className="flex items-start gap-4">
                  <div className="mt-1 flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-amber-100 text-amber-600">
                    <span className="material-symbols-outlined text-2xl">
                      lan
                    </span>
                  </div>
                  <div>
                    <h4 className="text-sm font-bold text-slate-900">
                      Titik Transit
                    </h4>
                    <p className="mt-0.5 text-sm text-slate-600">
                      Tiang Tumpuan / Jalur Lintasan Kabel
                    </p>
                  </div>
                </div>

                <div className="flex items-start gap-4">
                  <div className="mt-1 flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-emerald-100 text-emerald-600">
                    <span className="material-symbols-outlined text-2xl">
                      home_work
                    </span>
                  </div>
                  <div>
                    <h4 className="text-sm font-bold text-slate-900">
                      Titik Tujuan
                    </h4>
                    <p className="mt-0.5 text-sm text-slate-600">
                      Lokasi Akhir Perangkat Tenant (ONT/Modem)
                    </p>
                  </div>
                </div>
              </div>

              <div className="mt-8 rounded-xl bg-blue-600 p-5 text-white shadow-md shadow-blue-200">
                <div className="flex items-center gap-2 mb-2">
                  <span className="material-symbols-outlined text-xl">
                    info
                  </span>
                  <span className="text-xs font-black uppercase tracking-widest">
                    Info Jalur
                  </span>
                </div>
                <p className="text-sm leading-relaxed opacity-95">
                  Garis biru bercahaya menunjukkan estimasi jalur kabel FO yang
                  akan digelar dari provider hingga ke titik tujuan tenant.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>
    );
  }

  return (
    <section className="rounded-2xl bg-surface-container-lowest p-6 shadow-sm border border-slate-200 text-on-surface">
      <ToastStack onDismiss={dismissToast} toasts={toasts} />

      <div className="mb-5 flex flex-wrap items-start justify-between gap-4">
        <div>
          <p className="text-xs font-black uppercase tracking-widest text-on-surface-variant/70">
            FO Route Planner
          </p>
          <h3 className="text-2xl font-bold text-on-surface">
            Leaflet + OSRM Tactical Console
          </h3>
          <p className="mt-2 text-sm text-on-surface-variant">
            Tempatkan Titik A dan Titik B, hitung jalur otomatis via OSRM, atau
            aktifkan custom route untuk menggambar waypoint manual.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-2">
          {BASEMAP_OPTIONS.map((option) => (
            <button
              key={option.key}
              className={`inline-flex items-center justify-center rounded-lg border px-4 py-2 text-xs font-semibold uppercase tracking-wider transition disabled:cursor-not-allowed disabled:opacity-50 ${basemap === option.key ? "border-primary bg-primary text-white hover:bg-primary/90" : "border-slate-300 bg-white text-slate-700 hover:bg-slate-50"}`}
              onClick={() => setBasemap(option.key)}
              type="button"
            >
              {option.label}
            </button>
          ))}
        </div>
      </div>

      <div className="mb-4 grid grid-cols-1 gap-3 md:grid-cols-5">
        <div className="flex flex-col gap-1 rounded-xl border border-slate-200 bg-slate-50 p-4">
          <span className="text-[10px] font-bold uppercase tracking-widest text-slate-500">
            Titik Aktif
          </span>
          <span className="text-lg font-bold text-slate-900 break-words">
            {routeSummary.pointCount}
          </span>
        </div>
        <div className="flex flex-col gap-1 rounded-xl border border-slate-200 bg-slate-50 p-4">
          <span className="text-[10px] font-bold uppercase tracking-widest text-slate-500">
            Total Jarak
          </span>
          <span className="text-lg font-bold text-slate-900 break-words">
            {routeSummary.distanceLabel}
          </span>
        </div>
        <div className="flex flex-col gap-1 rounded-xl border border-slate-200 bg-slate-50 p-4">
          <span className="text-[10px] font-bold uppercase tracking-widest text-slate-500">
            Estimasi
          </span>
          <span className="text-lg font-bold text-slate-900 break-words">
            {routeSummary.durationLabel}
          </span>
        </div>
        <div className="flex flex-col gap-1 rounded-xl border border-slate-200 bg-slate-50 p-4">
          <span className="text-[10px] font-bold uppercase tracking-widest text-slate-500">
            Ruas Jalan
          </span>
          <span className="text-lg font-bold text-slate-900 break-words">
            {routeSummary.roadCount}
          </span>
        </div>
        <div className="flex flex-col gap-1 rounded-xl border border-slate-200 bg-slate-50 p-4">
          <span className="text-[10px] font-bold uppercase tracking-widest text-slate-500">
            Source
          </span>
          <span className="text-lg font-bold text-slate-900 break-words">
            {routeSummary.source}
          </span>
        </div>
      </div>

      <div className="mb-4 flex flex-wrap items-center gap-2">
        <button
          className={`inline-flex items-center justify-center rounded-lg border px-4 py-2 text-xs font-semibold uppercase tracking-wider transition disabled:cursor-not-allowed disabled:opacity-50 ${placementMode === "a" ? "border-primary bg-primary text-white hover:bg-primary/90" : "border-slate-300 bg-white text-slate-700 hover:bg-slate-50"}`}
          disabled={disabled}
          onClick={() => setPlacementMode("a")}
          type="button"
        >
          Set Titik A
        </button>
        <button
          className={`inline-flex items-center justify-center rounded-lg border px-4 py-2 text-xs font-semibold uppercase tracking-wider transition disabled:cursor-not-allowed disabled:opacity-50 ${placementMode === "b" ? "border-primary bg-primary text-white hover:bg-primary/90" : "border-slate-300 bg-white text-slate-700 hover:bg-slate-50"}`}
          disabled={disabled}
          onClick={() => setPlacementMode("b")}
          type="button"
        >
          Set Titik B
        </button>
        <button
          className={`inline-flex items-center justify-center rounded-lg border px-4 py-2 text-xs font-semibold uppercase tracking-wider transition disabled:cursor-not-allowed disabled:opacity-50 ${placementMode === "waypoint" ? "border-primary bg-primary text-white hover:bg-primary/90" : "border-slate-300 bg-white text-slate-700 hover:bg-slate-50"}`}
          disabled={disabled || !customRouteMode}
          onClick={() => setPlacementMode("waypoint")}
          type="button"
        >
          Tambah Waypoint
        </button>
        <button
          className={`inline-flex items-center justify-center rounded-lg border px-4 py-2 text-xs font-semibold uppercase tracking-wider transition disabled:cursor-not-allowed disabled:opacity-50 ${customRouteMode ? "border-amber-500 bg-amber-500 text-white hover:bg-amber-600" : "border-slate-300 bg-white text-slate-700 hover:bg-slate-50"}`}
          disabled={disabled}
          onClick={() => {
            setCustomRouteMode((previous) => !previous);
            pushToast(
              "Custom Route Mode",
              !customRouteMode
                ? "Mode waypoint manual aktif."
                : "Planner kembali memakai jalur otomatis OSRM.",
              "info",
            );
          }}
          type="button"
        >
          {customRouteMode ? "Custom Route ON" : "Custom Route OFF"}
        </button>
        <button
          className="inline-flex cursor-pointer items-center justify-center rounded-lg border border-slate-300 bg-white px-4 py-2 text-xs font-semibold uppercase tracking-wider text-slate-700 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-50"
          disabled={disabled}
          onClick={handleResetPlanner}
          type="button"
        >
          Reset Planner
        </button>
        <button
          className="inline-flex cursor-pointer items-center justify-center rounded-lg border border-slate-300 bg-white px-4 py-2 text-xs font-semibold uppercase tracking-wider text-slate-700 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-50"
          disabled={disabled || !routeData}
          onClick={handleExportGeoJson}
          type="button"
        >
          Export GeoJSON
        </button>
        <button
          className="inline-flex items-center justify-center rounded-lg border border-transparent bg-emerald-600 px-4 py-2 text-xs font-semibold uppercase tracking-wider text-white shadow-sm transition hover:bg-emerald-700 disabled:cursor-not-allowed disabled:opacity-50"
          disabled={disabled || !pointA || !pointB}
          onClick={handleApplyPlanner}
          type="button"
        >
          Terapkan ke Draft Jalur
        </button>
      </div>

      <div className="grid grid-cols-1 gap-4 xl:grid-cols-[1.3fr_0.9fr]">
        <div className="rounded-2xl border border-slate-200 bg-slate-50 p-3">
          <div className="overflow-hidden rounded-xl border border-slate-200">
            <MapContainer
              center={DEFAULT_CENTER}
              className="h-full min-h-[750px] w-full bg-slate-100"
              scrollWheelZoom
              zoom={DEFAULT_ZOOM}
            >
              <TileLayer
                attribution={selectedBasemap.attribution}
                url={selectedBasemap.url}
              />
              <MapClickHandler onMapClick={handleMapClick} />
              <MapViewportController
                fitCoordinates={mapFitCoordinates}
                fitRouteKey={`${routeData?.source ?? "none"}-${routeData?.distance ?? 0}-${routeData?.mode ?? "idle"}`}
                flyTarget={flyTarget}
              />

              {pointA && (
                <Marker
                  draggable={!disabled}
                  eventHandlers={{
                    dragend: (event) => {
                      const position = event.target.getLatLng();
                      handleMarkerDrag(
                        "provider",
                        pointA.id,
                        position.lat,
                        position.lng,
                      );
                    },
                  }}
                  icon={PROVIDER_ICON}
                  position={[pointA.lat, pointA.lng]}
                />
              )}
              {pointB && (
                <Marker
                  draggable={!disabled}
                  eventHandlers={{
                    dragend: (event) => {
                      const position = event.target.getLatLng();
                      handleMarkerDrag(
                        "customer",
                        pointB.id,
                        position.lat,
                        position.lng,
                      );
                    },
                  }}
                  icon={CUSTOMER_ICON}
                  position={[pointB.lat, pointB.lng]}
                />
              )}
              {manualWaypoints.map((point) => (
                <Marker
                  key={point.id}
                  draggable={!disabled}
                  eventHandlers={{
                    dragend: (event) => {
                      const position = event.target.getLatLng();
                      handleMarkerDrag(
                        "waypoint",
                        point.id,
                        position.lat,
                        position.lng,
                      );
                    },
                  }}
                  icon={WAYPOINT_ICON}
                  position={[point.lat, point.lng]}
                />
              ))}
              {routeData?.geoJson && (
                <>
                  <GeoJSON
                    data={routeData.geoJson}
                    style={() => routeGlowStyle}
                  />
                  <GeoJSON
                    data={routeData.geoJson}
                    style={() => routeMainStyle}
                  />
                </>
              )}
            </MapContainer>
          </div>
          {routeError && (
            <div className="mt-3 rounded-xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-700">
              {routeError}
            </div>
          )}
        </div>

        <div className="space-y-4">
          <section className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
            <div className="mb-3 flex items-center justify-between gap-3">
              <div>
                <p className="text-[10px] font-black uppercase tracking-widest text-slate-500">
                  OSRM Engine
                </p>
                <h4 className="text-lg font-bold text-slate-900">
                  Routing Controls
                </h4>
              </div>
              <select
                className="w-full rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm text-slate-900 outline-none transition focus:border-primary focus:ring-2 focus:ring-primary/20"
                disabled={disabled}
                onChange={(event) => setProfile(event.target.value)}
                value={profile}
              >
                <option value="driving">Driving</option>
                <option value="cycling">Cycling</option>
                <option value="foot">Walking</option>
              </select>
            </div>
            <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
              <div className="flex flex-col gap-1 rounded-xl border border-slate-200 bg-slate-50 p-3">
                <span className="text-[10px] font-bold uppercase tracking-widest text-slate-500">
                  Titik A
                </span>
                <span className="break-words text-sm font-bold text-slate-900">
                  {pointA
                    ? `${pointA.lat.toFixed(5)}, ${pointA.lng.toFixed(5)}`
                    : "Belum diisi"}
                </span>
              </div>
              <div className="flex flex-col gap-1 rounded-xl border border-slate-200 bg-slate-50 p-3">
                <span className="text-[10px] font-bold uppercase tracking-widest text-slate-500">
                  Titik B
                </span>
                <span className="break-words text-sm font-bold text-slate-900">
                  {pointB
                    ? `${pointB.lat.toFixed(5)}, ${pointB.lng.toFixed(5)}`
                    : "Belum diisi"}
                </span>
              </div>
            </div>
            <p className="mt-3 text-xs text-slate-500">
              Endpoint OSRM lokal:{" "}
              <span className="font-mono">{OSRM_LOCAL_HOST}</span>. Planner akan
              otomatis fallback ke router publik bila host lokal offline.
            </p>
            {isCalculating && (
              <p className="mt-2 text-xs font-bold uppercase tracking-[0.25em] text-primary">
                Menghitung rute...
              </p>
            )}
          </section>

          <section className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
            <p className="text-[10px] font-black uppercase tracking-widest text-slate-500">
              Search / Geocoding
            </p>
            <h4 className="text-lg font-bold text-slate-900">Cari Lokasi</h4>
            <form className="mt-3 flex gap-2" onSubmit={handleSearch}>
              <input
                className="w-full rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-primary focus:ring-2 focus:ring-primary/20"
                onChange={(event) => setSearchQuery(event.target.value)}
                placeholder="Cari nama jalan, gedung, area..."
                type="text"
                value={searchQuery}
              />
              <button
                className="inline-flex items-center justify-center rounded-lg border border-primary bg-primary px-4 py-2 text-xs font-semibold uppercase tracking-wider text-white transition hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-50"
                disabled={isSearching}
                type="submit"
              >
                {isSearching ? "..." : "Cari"}
              </button>
            </form>
            {searchError && (
              <p className="mt-2 text-xs text-rose-600">{searchError}</p>
            )}
            <div className="mt-3 max-h-[220px] space-y-2 overflow-auto pr-1">
              {searchResults.map((result) => (
                <div
                  key={result.place_id}
                  className="rounded-xl border border-slate-200 bg-slate-50 p-3"
                >
                  <p className="text-sm font-semibold text-slate-900">
                    {result.display_name}
                  </p>
                  <p className="mt-1 text-[11px] font-mono text-slate-500">
                    {Number(result.lat).toFixed(5)},{" "}
                    {Number(result.lon).toFixed(5)}
                  </p>
                  <div className="mt-3 flex flex-wrap gap-2">
                    <button
                      className="inline-flex cursor-pointer items-center justify-center rounded-lg border border-slate-300 bg-white px-4 py-2 text-xs font-semibold uppercase tracking-wider text-slate-700 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-50"
                      onClick={() => handlePickSearchResult(result, "a")}
                      type="button"
                    >
                      Jadikan A
                    </button>
                    <button
                      className="inline-flex cursor-pointer items-center justify-center rounded-lg border border-slate-300 bg-white px-4 py-2 text-xs font-semibold uppercase tracking-wider text-slate-700 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-50"
                      onClick={() => handlePickSearchResult(result, "b")}
                      type="button"
                    >
                      Jadikan B
                    </button>
                    <button
                      className="inline-flex cursor-pointer items-center justify-center rounded-lg border border-slate-300 bg-white px-4 py-2 text-xs font-semibold uppercase tracking-wider text-slate-700 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-50"
                      disabled={!customRouteMode}
                      onClick={() => handlePickSearchResult(result, "waypoint")}
                      type="button"
                    >
                      Waypoint
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </section>

          <section className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
            <p className="text-[10px] font-black uppercase tracking-widest text-slate-500">
              Manual Input
            </p>
            <h4 className="text-lg font-bold text-slate-900">
              Koordinat Lat / Lng
            </h4>
            <div className="mt-3 grid grid-cols-1 gap-3">
              <div className="rounded-xl border border-slate-200 bg-slate-50 p-3">
                <p className="mb-2 text-xs font-bold text-slate-700">Titik A</p>
                <div className="flex gap-2">
                  <input
                    className="w-full rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-primary focus:ring-2 focus:ring-primary/20"
                    onChange={(event) =>
                      setManualInput((prev) => ({
                        ...prev,
                        aLat: event.target.value,
                      }))
                    }
                    placeholder="Lat"
                    type="text"
                    value={manualInput.aLat}
                  />
                  <input
                    className="w-full rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-primary focus:ring-2 focus:ring-primary/20"
                    onChange={(event) =>
                      setManualInput((prev) => ({
                        ...prev,
                        aLng: event.target.value,
                      }))
                    }
                    placeholder="Lng"
                    type="text"
                    value={manualInput.aLng}
                  />
                  <button
                    className="inline-flex cursor-pointer items-center justify-center rounded-lg border border-slate-300 bg-white px-4 py-2 text-xs font-semibold uppercase tracking-wider text-slate-700 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-50"
                    onClick={() => handleManualInputApply("a")}
                    type="button"
                  >
                    Set A
                  </button>
                </div>
              </div>
              <div className="rounded-xl border border-slate-200 bg-slate-50 p-3">
                <p className="mb-2 text-xs font-bold text-slate-700">Titik B</p>
                <div className="flex gap-2">
                  <input
                    className="w-full rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-primary focus:ring-2 focus:ring-primary/20"
                    onChange={(event) =>
                      setManualInput((prev) => ({
                        ...prev,
                        bLat: event.target.value,
                      }))
                    }
                    placeholder="Lat"
                    type="text"
                    value={manualInput.bLat}
                  />
                  <input
                    className="w-full rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-primary focus:ring-2 focus:ring-primary/20"
                    onChange={(event) =>
                      setManualInput((prev) => ({
                        ...prev,
                        bLng: event.target.value,
                      }))
                    }
                    placeholder="Lng"
                    type="text"
                    value={manualInput.bLng}
                  />
                  <button
                    className="inline-flex cursor-pointer items-center justify-center rounded-lg border border-slate-300 bg-white px-4 py-2 text-xs font-semibold uppercase tracking-wider text-slate-700 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-50"
                    onClick={() => handleManualInputApply("b")}
                    type="button"
                  >
                    Set B
                  </button>
                </div>
              </div>
              <div className="rounded-xl border border-slate-200 bg-slate-50 p-3">
                <p className="mb-2 text-xs font-bold text-slate-700">
                  Waypoint
                </p>
                <div className="flex gap-2">
                  <input
                    className="w-full rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-primary focus:ring-2 focus:ring-primary/20"
                    onChange={(event) =>
                      setManualInput((prev) => ({
                        ...prev,
                        wLat: event.target.value,
                      }))
                    }
                    placeholder="Lat"
                    type="text"
                    value={manualInput.wLat}
                  />
                  <input
                    className="w-full rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-primary focus:ring-2 focus:ring-primary/20"
                    onChange={(event) =>
                      setManualInput((prev) => ({
                        ...prev,
                        wLng: event.target.value,
                      }))
                    }
                    placeholder="Lng"
                    type="text"
                    value={manualInput.wLng}
                  />
                  <button
                    className="inline-flex cursor-pointer items-center justify-center rounded-lg border border-slate-300 bg-white px-4 py-2 text-xs font-semibold uppercase tracking-wider text-slate-700 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-50"
                    disabled={!customRouteMode}
                    onClick={() => handleManualInputApply("waypoint")}
                    type="button"
                  >
                    Add W
                  </button>
                </div>
              </div>
            </div>
          </section>

          <section className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
            <p className="text-[10px] font-black uppercase tracking-widest text-slate-500">
              Custom Route
            </p>
            <h4 className="text-lg font-bold text-slate-900">
              Waypoint Editor
            </h4>
            <div className="mt-3 space-y-2">
              {manualWaypoints.length === 0 && (
                <p className="text-sm text-slate-500">
                  Belum ada waypoint manual.
                </p>
              )}
              {manualWaypoints.map((point, index) => (
                <div
                  key={point.id}
                  className="rounded-xl border border-slate-200 bg-slate-50 p-3"
                >
                  <div className="mb-2 flex items-center justify-between gap-2">
                    <p className="text-xs font-black uppercase tracking-widest text-primary">
                      Waypoint {index + 1}
                    </p>
                    <div className="flex gap-1">
                      <button
                        className="inline-flex items-center justify-center rounded bg-slate-200 p-1 text-slate-600 transition hover:bg-slate-300"
                        onClick={() => handleWaypointMove(point.id, "up")}
                        type="button"
                      >
                        <span className="material-symbols-outlined text-sm">
                          expand_less
                        </span>
                      </button>
                      <button
                        className="inline-flex items-center justify-center rounded bg-slate-200 p-1 text-slate-600 transition hover:bg-slate-300"
                        onClick={() => handleWaypointMove(point.id, "down")}
                        type="button"
                      >
                        <span className="material-symbols-outlined text-sm">
                          expand_more
                        </span>
                      </button>
                      <button
                        className="inline-flex items-center justify-center rounded bg-rose-100 p-1 text-rose-600 transition hover:bg-rose-200"
                        onClick={() => handleWaypointDelete(point.id)}
                        type="button"
                      >
                        <span className="material-symbols-outlined text-sm">
                          delete
                        </span>
                      </button>
                    </div>
                  </div>
                  <input
                    className="w-full rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-primary focus:ring-2 focus:ring-primary/20"
                    onChange={(event) =>
                      handleWaypointLabelChange(point.id, event.target.value)
                    }
                    placeholder="Label waypoint"
                    type="text"
                    value={point.label}
                  />
                  <p className="mt-2 text-[11px] font-mono text-slate-500">
                    {point.lat.toFixed(5)}, {point.lng.toFixed(5)}
                  </p>
                </div>
              ))}
            </div>
          </section>

          <section className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
            <p className="text-[10px] font-black uppercase tracking-widest text-slate-500">
              Route Analysis
            </p>
            <h4 className="text-lg font-bold text-slate-900">
              Jalan yang Dilewati
            </h4>
            <div className="mt-3 max-h-[280px] space-y-2 overflow-auto pr-1">
              {plannerRoads.length === 0 && (
                <p className="text-sm text-slate-500">
                  Belum ada data ruas jalan. Hitung rute otomatis atau tambah
                  waypoint manual.
                </p>
              )}
              {plannerRoads.map((road, index) => (
                <div
                  key={road.id}
                  className="rounded-xl border border-slate-200 bg-slate-50 px-3 py-2"
                >
                  <div className="flex items-center justify-between gap-3">
                    <p className="text-sm font-semibold text-slate-900">
                      {index + 1}. {road.name}
                    </p>
                    <span className="text-xs font-mono text-primary">
                      {formatDistance(road.distance)}
                    </span>
                  </div>
                  <p className="mt-1 text-[11px] text-slate-500">
                    {road.instruction}
                  </p>
                </div>
              ))}
            </div>
          </section>
        </div>
      </div>
    </section>
  );
}
