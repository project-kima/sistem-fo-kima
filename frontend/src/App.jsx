import { useCallback, useEffect, useMemo, useState } from "react";
import "./App.css";

const resolveApiBaseUrl = () => {
    const envBaseUrl = typeof import.meta.env.VITE_API_BASE_URL === "string"
        ? import.meta.env.VITE_API_BASE_URL.trim()
        : "";

    const fallbackHost = typeof window !== "undefined" && window.location?.hostname
        ? window.location.hostname
        : "localhost";
    const fallbackProtocol = typeof window !== "undefined" && window.location?.protocol === "https:"
        ? "https:"
        : "http:";

    const fallbackBaseUrl = `${fallbackProtocol}//${fallbackHost}:4000`;
    const normalizedBaseUrl = (envBaseUrl || fallbackBaseUrl).replace(/\/$/, "");

    // Keep fetch calls consistent with `${API_BASE_URL}/api/...` even when env includes `/api`.
    return normalizedBaseUrl.endsWith("/api")
        ? normalizedBaseUrl.slice(0, -4)
        : normalizedBaseUrl;
};

const API_BASE_URL = resolveApiBaseUrl();
const REQUEST_TIMEOUT_MS = 10_000;

const sidebarItems = [
    { key: "dashboard", label: "Dashboard", icon: "dashboard" },
    { key: "customers", label: "Pelanggan", icon: "groups" },
    { key: "monitoring", label: "Monitoring", icon: "monitor_heart" },
    { key: "trash", label: "Tempat Sampah", icon: "delete", separated: true },
];

const sectionMeta = {
    dashboard: {
        title: "Dashboard",
        description: "Ringkasan performa tenant, kontrak aktif, dan indikator operasional harian.",
    },
    monitoring: {
        title: "Monitoring",
        description: "Pantau aktivitas tenant, SLA, serta notifikasi anomali secara real-time.",
    },
    trash: {
        title: "Tempat Sampah",
        description: "Dokumen dan entitas yang dihapus sementara sebelum pemusnahan permanen.",
    },
};

const monitoringMonths = [
    "Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des",
];

const monthNames = [
    "",
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember",
];

const documentTypeOptions = [
    { value: "permohonan", label: "Permohonan" },
    { value: "penawaran", label: "Surat Penawaran Harga" },
    { value: "tanggapan", label: "Surat Tanggapan" },
    { value: "hasil_nego", label: "Surat Hasil Negosiasi" },
    { value: "BAK", label: "BAK" },
    { value: "kontrak", label: "Kontrak" },
    { value: "perpanjangan", label: "Perpanjangan" },
    { value: "pemutusan", label: "Pemutusan" },
    { value: "lainnya", label: "Lainnya" },
];

const documentTypeLabelMap = documentTypeOptions.reduce((accumulator, current) => {
    accumulator[current.value] = current.label;
    return accumulator;
}, {});

const documentTypeBadgeClass = {
    kontrak: "bg-blue-100 text-blue-700",
    invoice: "bg-emerald-100 text-emerald-700",
    pemutusan: "bg-red-100 text-red-700",
    perpanjangan: "bg-indigo-100 text-indigo-700",
    BAK: "bg-amber-100 text-amber-700",
    permohonan: "bg-slate-100 text-slate-700",
    penawaran: "bg-cyan-100 text-cyan-700",
    tanggapan: "bg-teal-100 text-teal-700",
    hasil_nego: "bg-violet-100 text-violet-700",
    lainnya: "bg-zinc-100 text-zinc-700",
};

const invoiceStatusLabelMap = {
    lunas: "Lunas",
    belum_bayar: "Belum Bayar",
    terlambat: "Terlambat",
    belum_ditagih: "Belum Ditagih",
};

const invoiceStatusBadgeClass = {
    lunas: "bg-emerald-100 text-emerald-700",
    belum_bayar: "bg-red-100 text-red-700",
    terlambat: "bg-orange-100 text-orange-700",
    belum_ditagih: "bg-amber-100 text-amber-700",
};

const contractStatusLabelMap = {
    aktif: "Aktif",
    expired: "Expired",
    terminated: "Terminated",
};

const contractStatusBadgeClass = {
    aktif: "bg-blue-100 text-blue-700",
    expired: "bg-amber-100 text-amber-700",
    terminated: "bg-red-100 text-red-700",
};

const timelineIconMap = {
    document: "article",
    contract: "description",
    contract_version: "history",
    invoice: "receipt_long",
    payment: "payments",
    todo: "task_alt",
};

const timelineColorMap = {
    document: "text-blue-700 bg-blue-50",
    contract: "text-amber-700 bg-amber-50",
    contract_version: "text-indigo-700 bg-indigo-50",
    invoice: "text-emerald-700 bg-emerald-50",
    payment: "text-emerald-700 bg-emerald-50",
    todo: "text-slate-700 bg-slate-100",
};

const normalizeErrorMessage = (result, fallback) => {
    if (Array.isArray(result?.message)) {
        return result.message.join(", ");
    }

    if (typeof result?.message === "string" && result.message.trim()) {
        return result.message;
    }

    return fallback;
};

const parseDateValue = (value) => {
    if (!value) {
        return null;
    }

    const raw = typeof value === "string" ? value : String(value);
    const parsed = raw.includes("T") ? new Date(raw) : new Date(`${raw}T00:00:00.000Z`);

    if (Number.isNaN(parsed.getTime())) {
        return null;
    }

    return parsed;
};

const formatDate = (value) => {
    const parsed = parseDateValue(value);
    if (!parsed) {
        return "-";
    }

    return new Intl.DateTimeFormat("id-ID", {
        day: "2-digit",
        month: "short",
        year: "numeric",
    }).format(parsed);
};

const formatDateTime = (value) => {
    const parsed = parseDateValue(value);
    if (!parsed) {
        return "-";
    }

    return new Intl.DateTimeFormat("id-ID", {
        day: "2-digit",
        month: "short",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit",
    }).format(parsed);
};

const formatCurrency = (value) => {
    const amount = Number(value ?? 0);
    return new Intl.NumberFormat("id-ID", {
        style: "currency",
        currency: "IDR",
        maximumFractionDigits: 0,
    }).format(Number.isNaN(amount) ? 0 : amount);
};

const toTitleCase = (value) => {
    if (!value) {
        return "-";
    }

    return String(value)
        .replaceAll("_", " ")
        .split(" ")
        .filter(Boolean)
        .map((segment) => segment[0].toUpperCase() + segment.slice(1))
        .join(" ");
};

const formatContractPeriod = (startDate, endDate) => {
    if (!startDate && !endDate) {
        return "-";
    }

    return `${formatDate(startDate)} - ${formatDate(endDate)}`;
};

const formatCoreAllocation = (coreType, coreTotal, sharingRatio) => {
    const normalizedTotal = Number(coreTotal ?? 0);
    if (!coreType || !Number.isFinite(normalizedTotal) || normalizedTotal <= 0) {
        return "-";
    }

    if (coreType === "sharing_core") {
        const normalizedRatio = typeof sharingRatio === "string" ? sharingRatio.trim() : "";
        return normalizedRatio
            ? `Sharing Core (Rasio ${normalizedRatio})`
            : "Sharing Core";
    }

    return `Core (${normalizedTotal})`;
};

const addDaysToIsoDate = (isoDate, days) => {
    const parsed = parseDateValue(isoDate);
    if (!parsed || !Number.isFinite(Number(days))) {
        return "";
    }

    const next = new Date(parsed);
    next.setUTCDate(next.getUTCDate() + Math.round(Number(days)));
    return next.toISOString().slice(0, 10);
};

const shiftIsoDateByBillingCycle = (isoDate, every, unit) => {
    const parsed = parseDateValue(isoDate);
    const normalizedEvery = Number(every);
    if (!parsed || !Number.isFinite(normalizedEvery) || normalizedEvery <= 0) {
        return "";
    }

    const next = new Date(parsed);
    if (unit === "hari") {
        next.setUTCDate(next.getUTCDate() + Math.round(normalizedEvery));
    } else if (unit === "tahun") {
        next.setUTCFullYear(next.getUTCFullYear() + Math.round(normalizedEvery));
    } else {
        next.setUTCMonth(next.getUTCMonth() + Math.round(normalizedEvery));
    }

    return next.toISOString().slice(0, 10);
};

const resolveBillingCycle = (billingPeriodMode, billingCustomEvery, billingCustomUnit) => {
    if (billingPeriodMode === "3bulanan") {
        return { every: 3, unit: "bulan" };
    }

    if (billingPeriodMode === "custom") {
        const every = Number(billingCustomEvery);
        if (!Number.isFinite(every) || every <= 0) {
            return null;
        }

        const unit = ["hari", "bulan", "tahun"].includes(billingCustomUnit)
            ? billingCustomUnit
            : "bulan";
        return { every: Math.round(every), unit };
    }

    return { every: 1, unit: "bulan" };
};

const buildInvoiceScheduleRows = (periodStartDate, periodEndDate, billingCycle) => {
    if (!periodStartDate || !periodEndDate || !billingCycle) {
        return [];
    }

    if (periodStartDate > periodEndDate) {
        return [];
    }

    const rows = [];
    let cursor = periodStartDate;
    let safetyCounter = 0;

    while (cursor <= periodEndDate && safetyCounter < 240) {
        safetyCounter += 1;

        const nextCursor = shiftIsoDateByBillingCycle(cursor, billingCycle.every, billingCycle.unit);
        if (!nextCursor || nextCursor <= cursor) {
            break;
        }

        const calculatedEnd = addDaysToIsoDate(nextCursor, -1);
        const periodRowEndDate = calculatedEnd && calculatedEnd < periodEndDate
            ? calculatedEnd
            : periodEndDate;

        rows.push({
            key: `auto-${cursor}-${periodRowEndDate}`,
            kind: "auto",
            periodStartDate: cursor,
            periodEndDate: periodRowEndDate,
            invoiceNumber: "",
            amount: "",
            paidAt: "",
            invoiceFileName: "",
            paymentProofFileName: "",
        });

        cursor = nextCursor;
    }

    return rows;
};

const getRemainingRentalDays = (contractEndDate) => {
    const parsedEndDate = parseDateValue(contractEndDate);
    if (!parsedEndDate) {
        return null;
    }

    const today = new Date();
    today.setUTCHours(0, 0, 0, 0);

    const normalizedEndDate = new Date(parsedEndDate);
    normalizedEndDate.setUTCHours(0, 0, 0, 0);

    return Math.ceil((normalizedEndDate.getTime() - today.getTime()) / (24 * 60 * 60 * 1000));
};

const isExternalFileUrl = (value) =>
    typeof value === "string" && /^https?:\/\//i.test(value.trim());

const mapCustomerToRow = (customer, index) => {
    const active = customer.status === "aktif";
    const activationFeeAmount = Number(customer.activationFeeAmount ?? 0);
    const activationFeePaidAt = customer.activationFeePaidAt ?? null;
    const ispList = Array.isArray(customer.isps)
        ? customer.isps
            .map((isp) => isp?.name)
            .filter((name) => typeof name === "string" && name.trim().length > 0)
        : [];
    const fallbackIspName = typeof customer.ispName === "string" && customer.ispName.trim()
        ? customer.ispName.trim()
        : "-";
    const primaryIsp = ispList[0] ?? fallbackIspName;
    const ispDisplay = ispList.length > 1
        ? `${primaryIsp} (+${ispList.length - 1})`
        : primaryIsp;

    return {
        id: customer.id,
        no: String(index + 1).padStart(2, "0"),
        isp: primaryIsp,
        ispDisplay,
        ispList: ispList.length > 0 ? ispList : [primaryIsp],
        name: customer.name ?? "-",
        status: active ? "Aktif" : "Non-aktif",
        active,
        contracts: Number(customer.contractCount ?? 0),
        documents: Number(customer.documentCount ?? 0),
        invoices: Number(customer.invoiceCount ?? 0),
        customerId: customer.customerCode ?? `CUST-${customer.id}`,
        rawStatus: customer.status,
        activationFeeAmount,
        activationFeePaidAt,
    };
};

const getMonthStatusClass = (status) => {
    if (status === "lunas") {
        return "bg-emerald-500";
    }

    if (status === "belum_bayar") {
        return "bg-red-500";
    }

    if (status === "terlambat") {
        return "bg-orange-400";
    }

    if (status === "belum_ditagih") {
        return "bg-amber-200";
    }

    return "bg-slate-100 opacity-40";
};

const createDefaultDocumentForm = () => ({
    jenisDokumen: "kontrak",
    nomorDokumen: "",
    tanggalDokumen: new Date().toISOString().slice(0, 10),
    contractId: "",
});

async function fetchJson(url, options) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => {
        controller.abort();
    }, REQUEST_TIMEOUT_MS);

    try {
        const response = await fetch(url, {
            ...options,
            signal: options?.signal ?? controller.signal,
        });
        const result = await response.json().catch(() => null);

        if (!response.ok) {
            throw new Error(
                normalizeErrorMessage(result, `Permintaan gagal (${response.status}).`),
            );
        }

        return result;
    } catch (error) {
        if (error instanceof Error && error.name === "AbortError") {
            throw new Error(
                `Permintaan melebihi ${REQUEST_TIMEOUT_MS / 1000} detik. Periksa backend di ${API_BASE_URL}.`,
            );
        }

        if (error instanceof TypeError) {
            throw new Error(`Gagal terhubung ke backend (${API_BASE_URL}).`);
        }

        throw error;
    } finally {
        clearTimeout(timeoutId);
    }
}

function App() {
    const [activeSection, setActiveSection] = useState("customers");
    const [selectedCustomer, setSelectedCustomer] = useState(null);
    const [selectedCustomerInitialTab, setSelectedCustomerInitialTab] = useState("overview");
    const [selectedCustomerContextIsp, setSelectedCustomerContextIsp] = useState(null);
    const [selectedIsp, setSelectedIsp] = useState(null);
    const [createMode, setCreateMode] = useState(null);
    const [customers, setCustomers] = useState([]);
    const [isLoadingCustomers, setIsLoadingCustomers] = useState(false);
    const [customersError, setCustomersError] = useState("");
    const [isps, setIsps] = useState([]);
    const [isLoadingIsps, setIsLoadingIsps] = useState(false);
    const [ispsError, setIspsError] = useState("");

    const loadCustomers = useCallback(async () => {
        setIsLoadingCustomers(true);
        setCustomersError("");

        try {
            const result = await fetchJson(`${API_BASE_URL}/api/customers`);
            const mappedCustomers = Array.isArray(result)
                ? result.map((customer, index) => mapCustomerToRow(customer, index))
                : [];

            setCustomers(mappedCustomers);
            setSelectedCustomer((previous) => {
                if (!previous) {
                    return previous;
                }

                return mappedCustomers.find((item) => item.id === previous.id) ?? previous;
            });

            return mappedCustomers;
        } catch (error) {
            setCustomersError(
                error instanceof Error
                    ? error.message
                    : "Terjadi kesalahan saat memuat daftar pelanggan.",
            );

            return [];
        } finally {
            setIsLoadingCustomers(false);
        }
    }, []);

    useEffect(() => {
        void loadCustomers();
    }, [loadCustomers]);

    const loadIsps = useCallback(async () => {
        setIsLoadingIsps(true);
        setIspsError("");

        try {
            const result = await fetchJson(`${API_BASE_URL}/api/isps`);
            setIsps(Array.isArray(result) ? result : []);
            return Array.isArray(result) ? result : [];
        } catch (error) {
            setIspsError(
                error instanceof Error
                    ? error.message
                    : "Terjadi kesalahan saat memuat daftar ISP.",
            );
            return [];
        } finally {
            setIsLoadingIsps(false);
        }
    }, []);

    useEffect(() => {
        void loadIsps();
    }, [loadIsps]);

    const ispOptions = useMemo(() => {
        const uniqueIsp = new Set();
        customers.forEach((item) => {
            if (Array.isArray(item.ispList) && item.ispList.length > 0) {
                item.ispList.forEach((ispName) => uniqueIsp.add(ispName));
                return;
            }

            if (item.isp) {
                uniqueIsp.add(item.isp);
            }
        });

        return Array.from(uniqueIsp).sort((left, right) => left.localeCompare(right));
    }, [customers]);

    const handleNavigate = (sectionKey) => {
        setActiveSection(sectionKey);
        setCreateMode(null);
        setSelectedIsp(null);

        if (sectionKey !== "customers") {
            setSelectedCustomer(null);
            setSelectedCustomerInitialTab("overview");
            setSelectedCustomerContextIsp(null);
        }
    };

    const handleOpenTenantDetail = (customer, initialTab = "overview", contextIsp = null) => {
        setActiveSection("customers");
        setCreateMode(null);
        setSelectedIsp(null);
        setSelectedCustomerInitialTab(initialTab);
        setSelectedCustomerContextIsp(contextIsp);
        setSelectedCustomer(customer);
    };

    const handleOpenIspDetail = (isp) => {
        setActiveSection("customers");
        setSelectedCustomer(null);
        setSelectedCustomerContextIsp(null);
        setCreateMode(null);
        setSelectedIsp(isp);
    };

    const handleOpenCreateTenant = () => {
        setActiveSection("customers");
        setSelectedCustomer(null);
        setSelectedCustomerInitialTab("overview");
        setSelectedCustomerContextIsp(null);
        setSelectedIsp(null);
        setCreateMode("tenant");
    };

    const handleOpenCreateIsp = () => {
        setActiveSection("customers");
        setSelectedCustomer(null);
        setSelectedCustomerInitialTab("overview");
        setSelectedCustomerContextIsp(null);
        setSelectedIsp(null);
        setCreateMode("isp");
    };

    const handleCancelCreate = () => {
        setCreateMode(null);
    };

    const handleEntitySaved = async (savedEntity, type) => {
        setCreateMode(null);
        const [refreshedCustomers, refreshedIsps] = await Promise.all([
            loadCustomers(),
            loadIsps(),
        ]);

        if (type === "isp") {
            const savedIspId = Number(savedEntity?.id);
            if (Number.isFinite(savedIspId)) {
                const targetIsp = refreshedIsps.find((item) => Number(item.id) === savedIspId);
                if (targetIsp) {
                    setSelectedIsp(targetIsp);
                }
            }
            return;
        }

        const savedCustomerId = Number(savedEntity?.id);
        if (Number.isFinite(savedCustomerId)) {
            const targetCustomer = refreshedCustomers.find((item) => item.id === savedCustomerId);
            if (targetCustomer) {
                setSelectedCustomerContextIsp(null);
                setSelectedCustomer(targetCustomer);
                return;
            }
        }
    };

    const handleOpenCustomerById = (customerId, initialTab = "overview") => {
        const targetCustomer = customers.find((item) => item.id === customerId);
        if (!targetCustomer) {
            return;
        }

        handleOpenTenantDetail(targetCustomer, initialTab);
    };

    if (activeSection === "dashboard") {
        return (
            <DashboardPage
                activeSection={activeSection}
                customers={customers}
                isLoadingCustomers={isLoadingCustomers}
                onNavigate={handleNavigate}
            />
        );
    }

    if (activeSection === "monitoring") {
        return (
            <MonitoringSpreadsheetPage
                activeSection={activeSection}
                ispOptions={ispOptions}
                onNavigate={handleNavigate}
                onOpenCustomerById={handleOpenCustomerById}
            />
        );
    }

    if (activeSection !== "customers") {
        return (
            <SectionPlaceholderPage
                activeSection={activeSection}
                onNavigate={handleNavigate}
            />
        );
    }

    if (createMode === "tenant") {
        return (
            <TenantAdminFormPage
                isps={isps}
                onCancel={handleCancelCreate}
                onNavigate={handleNavigate}
                onSaved={(entity) => handleEntitySaved(entity, "tenant")}
            />
        );
    }

    if (createMode === "isp") {
        return (
            <IspAdminFormPage
                onCancel={handleCancelCreate}
                onNavigate={handleNavigate}
                onSaved={(entity) => handleEntitySaved(entity, "isp")}
            />
        );
    }

    if (selectedIsp) {
        return (
            <IspDetailPage
                isp={selectedIsp}
                onBack={() => setSelectedIsp(null)}
                onNavigate={handleNavigate}
                onOpenTenant={(tenant, initialTab = "overview") =>
                    handleOpenTenantDetail(tenant, initialTab, selectedIsp)}
                onRefreshAll={async () => {
                    await Promise.all([loadCustomers(), loadIsps()]);
                }}
            />
        );
    }

    if (selectedCustomer) {
        return (
            <TenantDetailPage
                customer={selectedCustomer}
                contextIsp={selectedCustomerContextIsp}
                initialTab={selectedCustomerInitialTab}
                onBack={() => {
                    setSelectedCustomer(null);
                    setSelectedCustomerInitialTab("overview");
                    setSelectedCustomerContextIsp(null);
                }}
                onCreateIsp={handleOpenCreateIsp}
                onNavigate={handleNavigate}
                onRefreshAll={async () => {
                    await Promise.all([loadCustomers(), loadIsps()]);
                }}
            />
        );
    }

    return (
        <CustomerWorkspacePage
            activeSection={activeSection}
            customers={customers}
            isps={isps}
            error={customersError}
            secondaryError={ispsError}
            isLoading={isLoadingCustomers || isLoadingIsps}
            onNavigate={handleNavigate}
            onOpenTenant={handleOpenTenantDetail}
            onOpenIsp={handleOpenIspDetail}
            onOpenCreateTenant={handleOpenCreateTenant}
            onOpenCreateIsp={handleOpenCreateIsp}
            onRefresh={async () => {
                await Promise.all([loadCustomers(), loadIsps()]);
            }}
        />
    );
}

function AppShell({ activeSection, onNavigate, children }) {
    const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

    const handleMobileNavigate = (sectionKey) => {
        onNavigate(sectionKey);
        setIsMobileMenuOpen(false);
    };

    return (
        <div className="bg-surface text-on-surface">
            <TopNav onToggleMenu={() => setIsMobileMenuOpen((prev) => !prev)} />
            {isMobileMenuOpen && (
                <MobileDropdownMenu
                    activeSection={activeSection}
                    onClose={() => setIsMobileMenuOpen(false)}
                    onNavigate={handleMobileNavigate}
                />
            )}
            <Sidebar activeSection={activeSection} onNavigate={onNavigate} />
            <main className="min-h-screen px-6 pb-10 pt-24 md:ml-64 md:px-12 md:pb-12">{children}</main>
        </div>
    );
}

function TopNav({ onToggleMenu }) {
    return (
        <nav className="fixed top-0 z-40 flex h-16 w-full items-center justify-between bg-white/80 px-6 font-manrope antialiased shadow-sm backdrop-blur-xl md:ml-64 md:w-[calc(100%-16rem)] md:px-8">
            <div className="flex items-center gap-3 md:gap-8">
                <button
                    className="inline-flex h-9 w-9 items-center justify-center rounded-lg text-slate-600 transition-colors hover:bg-slate-100 md:hidden"
                    onClick={onToggleMenu}
                    type="button"
                >
                    <span className="material-symbols-outlined">menu</span>
                </button>
                <div className="hidden items-center gap-6 md:flex">
                    <div className="flex items-center gap-3 rounded-lg bg-surface-container-low px-4 py-2">
                        <span className="material-symbols-outlined text-xl text-outline">hub</span>
                        <div>
                            <p className="text-sm font-bold text-on-surface">KIMA Arsip Monitoring</p>
                            <p className="text-[10px] uppercase tracking-wider text-on-surface-variant">
                                Sinkronisasi backend aktif
                            </p>
                        </div>
                    </div>
                </div>
            </div>

            <div className="flex items-center gap-6">
                <button
                    className="rounded-lg p-2 text-slate-500 transition-all hover:bg-slate-50"
                    type="button"
                >
                    <span className="material-symbols-outlined">notifications</span>
                </button>
                <div className="hidden items-center gap-3 border-l border-slate-100 pl-4 md:flex">
                    <div className="text-right">
                        <p className="text-sm font-semibold text-on-surface">Administrator</p>
                        <p className="text-[10px] uppercase tracking-wider text-on-surface-variant">
                            Super Admin
                        </p>
                    </div>
                    <img
                        alt="Administrator Profile"
                        className="h-10 w-10 rounded-full border-2 border-surface-container-high object-cover"
                        src="https://lh3.googleusercontent.com/aida-public/AB6AXuBAFhnZ3sLh08K-pb9OHZ3RVbGsMO5bKg2zux3NkoQNNOv96Mff-nuHjRBNqlG8PKMPx0E-6VsMGTfB_Jn7lpTk0cWXlblrf-mzL1KZ3O724-QrQBwXPmLINGHLBuxACZGsByzSGBD6Yt9GVvuswzU7_IhGniplwUFCUhvp7w5cU0m_k8DzEjXtMaYsXa-5x15vort0mEzRr9ygaZgu9n6dL3xd-XNV_AxamcvQyVEuceozL2mSLxCaP6gqaGvVKvIN6DZvZzpMQh8"
                    />
                </div>
            </div>
        </nav>
    );
}

function MobileDropdownMenu({ activeSection, onNavigate, onClose }) {
    return (
        <div className="fixed inset-x-0 top-16 z-40 px-4 md:hidden">
            <div className="rounded-2xl border border-slate-100 bg-white/95 p-2 shadow-xl backdrop-blur">
                <div className="mb-1 flex items-center justify-between px-2 py-1">
                    <p className="text-[10px] font-bold uppercase tracking-widest text-on-surface-variant">
                        Menu Navigasi
                    </p>
                    <button
                        className="rounded-md p-1 text-slate-500 transition-colors hover:bg-slate-100"
                        onClick={onClose}
                        type="button"
                    >
                        <span className="material-symbols-outlined text-lg">close</span>
                    </button>
                </div>

                <div className="space-y-1">
                    {sidebarItems.map((item) => {
                        const isActive = activeSection === item.key;
                        return (
                            <div key={item.key} className={item.separated ? "mt-2 border-t border-slate-100 pt-2" : ""}>
                                <button
                                    className={`flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-left text-sm ${isActive
                                        ? "bg-blue-50/70 font-bold text-blue-900"
                                        : "text-slate-600 transition-colors hover:bg-slate-100"
                                        }`}
                                    onClick={() => onNavigate(item.key)}
                                    type="button"
                                >
                                    <span
                                        className="material-symbols-outlined"
                                        style={isActive ? { fontVariationSettings: "'FILL' 1" } : undefined}
                                    >
                                        {item.icon}
                                    </span>
                                    <span>{item.label}</span>
                                </button>
                            </div>
                        );
                    })}
                </div>
            </div>
        </div>
    );
}

function Sidebar({ activeSection, onNavigate }) {
    return (
        <aside className="fixed left-0 top-0 z-50 hidden h-screen w-64 flex-col bg-slate-50/80 px-4 py-8 font-manrope text-sm font-medium backdrop-blur-xl md:flex">
            <div className="mb-10 px-2">
                <div className="flex items-center gap-3">
                    <img
                        alt=""
                        aria-hidden="true"
                        className="h-10 w-10 object-contain"
                        src="/favicon.svg"
                    />
                    <div>
                        <p className="text-lg font-extrabold tracking-tight text-blue-900">KIMA</p>
                        <p className="text-xs font-medium text-on-surface-variant">Dokumen Arsip</p>
                    </div>
                </div>
            </div>

            <nav className="flex-grow space-y-2">
                {sidebarItems.map((item) => {
                    const isActive = activeSection === item.key;
                    return (
                        <div key={item.key}>
                            <button
                                className={`flex w-full items-center gap-3 px-4 py-3 text-left font-manrope text-sm tracking-tight ${isActive
                                    ? "rounded-l-lg border-r-4 border-blue-900 bg-blue-50/50 font-bold text-blue-900"
                                    : "rounded-lg text-slate-500 transition-all hover:bg-blue-50/30 hover:text-blue-800"
                                    }`}
                                onClick={() => onNavigate(item.key)}
                                type="button"
                            >
                                <span
                                    className="material-symbols-outlined"
                                    style={
                                        isActive
                                            ? { fontVariationSettings: "'FILL' 1" }
                                            : undefined
                                    }
                                >
                                    {item.icon}
                                </span>
                                <span>{item.label}</span>
                            </button>
                        </div>
                    );
                })}
            </nav>
        </aside>
    );
}

function DashboardPage({
    activeSection,
    onNavigate,
    customers,
    isLoadingCustomers,
}) {
    const currentYear = String(new Date().getUTCFullYear());
    const [billingSummary, setBillingSummary] = useState({
        lunas: 0,
        belum_bayar: 0,
        terlambat: 0,
        belum_ditagih: 0,
    });
    const [alerts, setAlerts] = useState([]);
    const [insights, setInsights] = useState(null);
    const [isLoadingOperational, setIsLoadingOperational] = useState(false);
    const [operationalError, setOperationalError] = useState("");

    const loadOperationalData = useCallback(async () => {
        setIsLoadingOperational(true);
        setOperationalError("");

        try {
            const [billingResult, alertsResult, insightsResult] = await Promise.all([
                fetchJson(`${API_BASE_URL}/api/monitoring/billing?year=${currentYear}`),
                fetchJson(`${API_BASE_URL}/api/monitoring/alerts?year=${currentYear}`),
                fetchJson(`${API_BASE_URL}/api/monitoring/insights?year=${currentYear}`),
            ]);

            const summary = billingResult?.summary ?? {};
            setBillingSummary({
                lunas: Number(summary.lunas ?? 0),
                belum_bayar: Number(summary.belum_bayar ?? 0),
                terlambat: Number(summary.terlambat ?? 0),
                belum_ditagih: Number(summary.belum_ditagih ?? 0),
            });

            const parsedAlerts = Array.isArray(alertsResult)
                ? alertsResult
                : Array.isArray(alertsResult?.alerts)
                    ? alertsResult.alerts
                    : [];
            setAlerts(parsedAlerts);

            const parsedInsights =
                insightsResult
                    && Array.isArray(insightsResult?.months)
                    && insightsResult?.totals
                    ? insightsResult
                    : null;
            setInsights(parsedInsights);
        } catch (error) {
            setOperationalError(
                error instanceof Error
                    ? error.message
                    : "Terjadi kesalahan saat memuat data operasional dashboard.",
            );
        } finally {
            setIsLoadingOperational(false);
        }
    }, [currentYear]);

    useEffect(() => {
        void loadOperationalData();
    }, [loadOperationalData]);

    const totalCustomers = customers.length;
    const activeCustomers = customers.filter((customer) => customer.active).length;
    const inactiveCustomers = totalCustomers - activeCustomers;
    const overdueInvoices = Number(billingSummary.terlambat ?? 0);
    const unpaidInvoices = Number(billingSummary.belum_bayar ?? 0);
    const totalAlerts = alerts.length;
    const issueCounts = {
        missingContract: alerts.filter((alert) => alert.code === "missing_contract").length,
        missingInvoice: alerts.filter((alert) => ["missing_invoice_current_month", "invoice_not_uploaded", "payment_overdue"].includes(alert.code)).length,
        contractExpiring: alerts.filter((alert) => ["contract_expiring", "bak_missing"].includes(alert.code)).length,
        activationFee: alerts.filter((alert) => alert.code === "activation_fee_unpaid").length,
        terminationDoc: alerts.filter((alert) => ["has_termination_document", "missing_required_document"].includes(alert.code)).length,
    };

    const insightMonths = Array.isArray(insights?.months) ? insights.months : [];
    const insightTotals = insights?.totals ?? {
        revenuePaid: 0,
        revenueProjected: 0,
        estimatedProfit: 0,
        averageActiveRentals: 0,
    };

    const maxRevenue = Math.max(
        1,
        ...insightMonths.map((item) =>
            Math.max(Number(item.revenuePaid ?? 0), Number(item.revenueProjected ?? 0))),
    );

    const firstHalfAverageRentals = insightMonths.length > 0
        ? Math.round(
            insightMonths
                .slice(0, 6)
                .reduce((sum, item) => sum + Number(item.activeRentals ?? 0), 0) / 6,
        )
        : 0;
    const secondHalfAverageRentals = insightMonths.length > 0
        ? Math.round(
            insightMonths
                .slice(6)
                .reduce((sum, item) => sum + Number(item.activeRentals ?? 0), 0) / 6,
        )
        : 0;
    const rentalDelta = secondHalfAverageRentals - firstHalfAverageRentals;

    let biggestDrop = { month: null, delta: 0 };
    insightMonths.forEach((item, index) => {
        if (index === 0) {
            return;
        }

        const previous = Number(insightMonths[index - 1]?.activeRentals ?? 0);
        const current = Number(item.activeRentals ?? 0);
        const delta = current - previous;

        if (delta < biggestDrop.delta) {
            biggestDrop = {
                month: item.month,
                delta,
            };
        }
    });

    const totalStatusCells =
        Number(billingSummary.lunas)
        + Number(billingSummary.belum_bayar)
        + Number(billingSummary.terlambat)
        + Number(billingSummary.belum_ditagih);

    const statusVisual = [
        {
            key: "lunas",
            label: "Lunas",
            value: Number(billingSummary.lunas),
            barClass: "bg-emerald-500",
            textClass: "text-emerald-700",
        },
        {
            key: "belum_bayar",
            label: "Belum Bayar",
            value: Number(billingSummary.belum_bayar),
            barClass: "bg-red-500",
            textClass: "text-red-700",
        },
        {
            key: "terlambat",
            label: "Terlambat",
            value: Number(billingSummary.terlambat),
            barClass: "bg-orange-500",
            textClass: "text-orange-700",
        },
        {
            key: "belum_ditagih",
            label: "Belum Ditagih",
            value: Number(billingSummary.belum_ditagih),
            barClass: "bg-amber-400",
            textClass: "text-amber-700",
        },
    ];

    return (
        <AppShell activeSection={activeSection} onNavigate={onNavigate}>
            <div className="mx-auto max-w-7xl space-y-8">
                <section className="flex flex-col items-start justify-between gap-4 lg:flex-row lg:items-end">
                    <div className="max-w-3xl">
                        <h1 className="mb-1 text-3xl font-extrabold tracking-tight text-primary">
                            Dashboard Visual Ringkasan
                        </h1>
                        <p className="text-on-surface-variant">
                            Menampilkan visual diagram keuangan, tren sewa, dan indikator utama lintas pelanggan.
                            Detail operasional lengkap tersedia pada halaman Monitoring.
                        </p>
                    </div>

                    <div className="flex items-center gap-3">
                        <button
                            className="inline-flex items-center gap-2 rounded-lg bg-white px-4 py-2 text-sm font-semibold text-primary shadow-sm ring-1 ring-primary/20 transition-opacity hover:opacity-90"
                            onClick={() => {
                                void loadOperationalData();
                            }}
                            type="button"
                        >
                            <span className="material-symbols-outlined text-base">sync</span>
                            Sinkronkan
                        </button>

                        <button
                            className="inline-flex items-center gap-2 rounded-lg bg-primary px-4 py-2 text-sm font-semibold text-white shadow-md transition-opacity hover:opacity-90"
                            onClick={() => onNavigate("monitoring")}
                            type="button"
                        >
                            <span className="material-symbols-outlined text-base">monitor_heart</span>
                            Buka Monitoring Detail
                        </button>
                    </div>
                </section>

                {(isLoadingCustomers || isLoadingOperational) && (
                    <div className="rounded-xl border border-blue-100 bg-blue-50 px-5 py-4 text-sm text-blue-700">
                        Memuat data dashboard dari backend...
                    </div>
                )}

                {operationalError && (
                    <div className="rounded-xl border border-red-200 bg-red-50 px-5 py-4 text-sm text-red-700">
                        {operationalError}
                    </div>
                )}

                <section className="grid grid-cols-1 gap-6 md:grid-cols-4">
                    <MetricCard
                        accentClass="border-primary"
                        title="Pendapatan Terealisasi"
                        value={formatCurrency(insightTotals.revenuePaid)}
                        helper={`Tahun ${currentYear}`}
                    />
                    <MetricCard
                        accentClass="border-emerald-600"
                        title="Estimasi Keuntungan"
                        value={formatCurrency(insightTotals.estimatedProfit)}
                        helper="Asumsi margin 28%"
                    />
                    <MetricCard
                        accentClass="border-blue-600"
                        title="Proyeksi Pendapatan"
                        value={formatCurrency(insightTotals.revenueProjected)}
                        helper="Termasuk invoice belum lunas"
                    />
                    <MetricCard
                        accentClass="border-amber-500"
                        title="Rata-rata Sewa Aktif"
                        value={String(insightTotals.averageActiveRentals)}
                        helper={`Total kendala: ${totalAlerts}`}
                    />
                </section>

                <section className="grid grid-cols-1 gap-6 xl:grid-cols-5">
                    <div className="xl:col-span-3 rounded-2xl border border-slate-100 bg-white p-6 shadow-sm">
                        <div className="mb-4 flex items-center justify-between gap-3">
                            <div>
                                <p className="text-xs font-black uppercase tracking-widest text-primary">Diagram Pendapatan</p>
                                <h2 className="text-xl font-bold text-on-surface">Perbandingan Pendapatan per Bulan</h2>
                            </div>
                            <span className="rounded-full bg-blue-50 px-3 py-1 text-xs font-bold text-blue-700">
                                Tahun {currentYear}
                            </span>
                        </div>

                        {insightMonths.length === 0 ? (
                            <p className="rounded-lg bg-slate-50 px-4 py-3 text-sm text-on-surface-variant">
                                Data pendapatan belum tersedia untuk divisualisasikan.
                            </p>
                        ) : (
                            <div className="space-y-4">
                                <div className="flex items-center gap-4 text-xs font-bold">
                                    <span className="inline-flex items-center gap-2 text-emerald-700">
                                        <span className="h-2.5 w-2.5 rounded bg-emerald-500"></span>
                                        Terealisasi
                                    </span>
                                    <span className="inline-flex items-center gap-2 text-blue-700">
                                        <span className="h-2.5 w-2.5 rounded bg-blue-500"></span>
                                        Proyeksi
                                    </span>
                                </div>

                                <div className="overflow-x-auto">
                                    <div className="flex min-w-[760px] items-end gap-4 pb-2">
                                        {insightMonths.map((item) => {
                                            const paid = Number(item.revenuePaid ?? 0);
                                            const projected = Number(item.revenueProjected ?? 0);
                                            const paidHeight = Math.max(
                                                paid > 0 ? 10 : 0,
                                                Math.round((paid / maxRevenue) * 170),
                                            );
                                            const projectedHeight = Math.max(
                                                projected > 0 ? 10 : 0,
                                                Math.round((projected / maxRevenue) * 170),
                                            );

                                            return (
                                                <div key={item.month} className="flex flex-col items-center gap-2">
                                                    <div className="flex h-[190px] items-end gap-1">
                                                        <div
                                                            className="w-4 rounded-t bg-emerald-500"
                                                            style={{ height: `${paidHeight}px` }}
                                                            title={`Terealisasi: ${formatCurrency(paid)}`}
                                                        ></div>
                                                        <div
                                                            className="w-4 rounded-t bg-blue-500"
                                                            style={{ height: `${projectedHeight}px` }}
                                                            title={`Proyeksi: ${formatCurrency(projected)}`}
                                                        ></div>
                                                    </div>

                                                    <p className="text-[11px] font-bold text-slate-600">
                                                        {monitoringMonths[item.month - 1]}
                                                    </p>
                                                </div>
                                            );
                                        })}
                                    </div>
                                </div>
                            </div>
                        )}
                    </div>

                    <div className="xl:col-span-2 rounded-2xl border border-slate-100 bg-white p-6 shadow-sm">
                        <div className="mb-4">
                            <p className="text-xs font-black uppercase tracking-widest text-primary">Tren Jumlah Sewa</p>
                            <h2 className="text-xl font-bold text-on-surface">Naik Turun Sewa Aktif</h2>
                        </div>

                        <div className="space-y-3">
                            <div className="rounded-xl border border-slate-100 bg-blue-50/70 px-4 py-3">
                                <div className="mb-1 flex items-center justify-between">
                                    <p className="text-sm font-bold text-blue-900">Rata-rata Semester 1</p>
                                    <p className="text-sm font-black text-blue-900">{firstHalfAverageRentals}</p>
                                </div>
                            </div>

                            <div className="rounded-xl border border-slate-100 bg-slate-50 px-4 py-3">
                                <div className="mb-1 flex items-center justify-between">
                                    <p className="text-sm font-bold text-slate-700">Rata-rata Semester 2</p>
                                    <p className="text-sm font-black text-slate-700">{secondHalfAverageRentals}</p>
                                </div>
                            </div>

                            <div className={`rounded-xl border px-4 py-3 ${rentalDelta < 0 ? "border-red-200 bg-red-50" : "border-emerald-200 bg-emerald-50"}`}>
                                <p className="text-xs font-bold uppercase tracking-wider text-slate-600">
                                    Perubahan Sewa
                                </p>
                                <p className={`mt-1 text-2xl font-black ${rentalDelta < 0 ? "text-red-700" : "text-emerald-700"}`}>
                                    {rentalDelta > 0 ? `+${rentalDelta}` : rentalDelta}
                                </p>
                            </div>

                            <div className="rounded-xl border border-slate-100 bg-white px-4 py-3">
                                <p className="text-xs font-bold uppercase tracking-wider text-slate-500">
                                    Penurunan Terbesar
                                </p>
                                <p className="mt-1 text-sm font-bold text-blue-900">
                                    {biggestDrop.month
                                        ? `${monitoringMonths[biggestDrop.month - 1]} (${biggestDrop.delta})`
                                        : "Tidak ada penurunan signifikan"}
                                </p>
                            </div>
                        </div>
                    </div>
                </section>

                <section className="grid grid-cols-1 gap-6 lg:grid-cols-2">
                    <div className="rounded-2xl border border-slate-100 bg-white p-6 shadow-sm">
                        <h3 className="mb-4 text-lg font-bold text-on-surface">Status Billing Tahunan</h3>
                        <div className="space-y-3">
                            {totalStatusCells === 0 && (
                                <p className="rounded-lg bg-slate-50 px-4 py-3 text-sm text-on-surface-variant">
                                    Data billing belum tersedia untuk divisualisasikan.
                                </p>
                            )}

                            {statusVisual.map((item) => {
                                const percentage = totalStatusCells > 0
                                    ? Math.round((item.value / totalStatusCells) * 100)
                                    : 0;

                                return (
                                    <div
                                        key={item.key}
                                        className="rounded-xl border border-slate-100 bg-slate-50/70 px-4 py-3"
                                    >
                                        <div className="mb-2 flex items-center justify-between gap-2">
                                            <p className="text-sm font-bold text-on-surface">{item.label}</p>
                                            <p className={`text-xs font-bold ${item.textClass}`}>
                                                {item.value} ({percentage}%)
                                            </p>
                                        </div>

                                        <div className="h-2 w-full rounded-full bg-slate-200">
                                            <div
                                                className={`h-2 rounded-full ${item.barClass}`}
                                                style={{ width: `${percentage}%` }}
                                            ></div>
                                        </div>
                                    </div>
                                );
                            })}
                        </div>
                    </div>

                    <div className="space-y-6">
                        <div className="rounded-2xl border border-slate-100 bg-white p-6 shadow-sm">
                            <h3 className="mb-4 text-lg font-bold text-on-surface">Ringkasan Kendala</h3>
                            <div className="space-y-3">
                                <IssueCountRow label="Kontrak belum tersedia" value={issueCounts.missingContract} />
                                <IssueCountRow label="Invoice bulan berjalan belum ada" value={issueCounts.missingInvoice} />
                                <IssueCountRow label="Kontrak mendekati habis" value={issueCounts.contractExpiring} />
                                <IssueCountRow label="Biaya aktivasi belum dibayar" value={issueCounts.activationFee} />
                                <IssueCountRow label="Dokumen terminasi terdeteksi" value={issueCounts.terminationDoc} />
                            </div>
                        </div>

                        <div className="rounded-2xl bg-primary p-6 text-white">
                            <p className="mb-2 text-xs font-black uppercase tracking-widest text-blue-200">Status Data Visual</p>
                            <h4 className="mb-4 text-xl font-bold leading-tight">
                                Dashboard menampilkan diagram keuangan dan tren sewa sebagai ringkasan cepat manajemen.
                            </h4>
                            <div className="space-y-2 text-sm text-blue-100/90">
                                <p>Total pelanggan: <span className="font-bold text-white">{totalCustomers}</span></p>
                                <p>Pelanggan aktif: <span className="font-bold text-white">{activeCustomers}</span></p>
                                <p>Pelanggan non-aktif: <span className="font-bold text-white">{inactiveCustomers}</span></p>
                                <p>Invoice belum bayar/terlambat: <span className="font-bold text-white">{unpaidInvoices} / {overdueInvoices}</span></p>
                                <p>Untuk daftar tindakan dan konfirmasi, gunakan halaman Monitoring.</p>
                            </div>
                        </div>
                    </div>
                </section>
            </div>
        </AppShell>
    );
}

function MetricCard({ title, value, helper, accentClass }) {
    return (
        <div className={`rounded-lg border-l-4 bg-surface-container-lowest p-6 shadow-sm ${accentClass}`}>
            <p className="mb-1 text-xs font-bold uppercase tracking-widest text-on-surface-variant">{title}</p>
            <h3 className="text-3xl font-extrabold text-on-surface">{value}</h3>
            {helper && <p className="mt-2 text-xs text-on-surface-variant">{helper}</p>}
        </div>
    );
}

function IssueCountRow({ label, value }) {
    return (
        <div className="flex items-center justify-between rounded-xl border border-slate-100 bg-slate-50/70 px-4 py-3">
            <p className="text-sm font-semibold text-on-surface">{label}</p>
            <span className="rounded-full bg-blue-100 px-2.5 py-1 text-xs font-bold text-blue-700">
                {value}
            </span>
        </div>
    );
}

function CustomerAdminFormPage({ mode, customer, ispOptions = [], onCancel, onNavigate, onSaved }) {
    const isEditMode = mode === "edit";
    const isActivationFeeLocked = isEditMode && Boolean(customer?.activationFeePaidAt);
    const resolvedInitialIsp = Array.isArray(customer?.ispList) && customer.ispList.length > 0
        ? customer.ispList.join(", ")
        : customer?.isp ?? "";
    const [form, setForm] = useState({
        name: customer?.name ?? "",
        ispName: resolvedInitialIsp,
        status: customer?.rawStatus ?? "aktif",
        contractNumber: "",
        activationFeeAmount: String(Number(customer?.activationFeeAmount ?? 0)),
        activationFeePaidAt: customer?.activationFeePaidAt ? String(customer.activationFeePaidAt).slice(0, 10) : "",
        contractInitialStartDate: "",
        contractRunningStartDate: "",
        contractRunningEndDate: "",
        contractCoreType: "core",
        contractCoreTotal: "4",
        contractSharingRatioLeft: "1",
        contractSharingRatioRight: "2",
        billingPeriodMode: "bulanan",
        billingCustomEvery: "",
        billingCustomUnit: "bulan",
    });
    const [submitError, setSubmitError] = useState("");
    const [submitSuccess, setSubmitSuccess] = useState("");
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [invoiceRows, setInvoiceRows] = useState([]);
    const ispDatalistId = "customer-admin-isp-options";

    useEffect(() => {
        const nextIspValue = Array.isArray(customer?.ispList) && customer.ispList.length > 0
            ? customer.ispList.join(", ")
            : customer?.isp ?? "";

        setForm({
            name: customer?.name ?? "",
            ispName: nextIspValue,
            status: customer?.rawStatus ?? "aktif",
            contractNumber: "",
            activationFeeAmount: String(Number(customer?.activationFeeAmount ?? 0)),
            activationFeePaidAt: customer?.activationFeePaidAt ? String(customer.activationFeePaidAt).slice(0, 10) : "",
            contractInitialStartDate: "",
            contractRunningStartDate: "",
            contractRunningEndDate: "",
            contractCoreType: "core",
            contractCoreTotal: "4",
            contractSharingRatioLeft: "1",
            contractSharingRatioRight: "2",
            billingPeriodMode: "bulanan",
            billingCustomEvery: "",
            billingCustomUnit: "bulan",
        });
        setInvoiceRows([]);
        setSubmitError("");
        setSubmitSuccess("");
    }, [
        isEditMode,
        customer?.id,
        customer?.name,
        customer?.isp,
        customer?.ispList,
        customer?.rawStatus,
        customer?.activationFeeAmount,
        customer?.activationFeePaidAt,
    ]);

    useEffect(() => {
        if (isEditMode) {
            setInvoiceRows([]);
            return;
        }

        const hasRunningPeriod = Boolean(
            form.contractRunningStartDate
            && form.contractRunningEndDate
            && form.contractRunningStartDate <= form.contractRunningEndDate,
        );
        const billingCycle = resolveBillingCycle(
            form.billingPeriodMode,
            form.billingCustomEvery,
            form.billingCustomUnit,
        );

        if (!hasRunningPeriod || !billingCycle) {
            setInvoiceRows((previousRows) => previousRows.filter((row) => row.kind === "manual"));
            return;
        }

        const autoRows = buildInvoiceScheduleRows(
            form.contractRunningStartDate,
            form.contractRunningEndDate,
            billingCycle,
        );

        setInvoiceRows((previousRows) => {
            const previousRowMap = new Map(previousRows.map((row) => [row.key, row]));
            const manualRows = previousRows.filter((row) => row.kind === "manual");

            const mergedAutoRows = autoRows.map((row) => {
                const previousRow = previousRowMap.get(row.key);
                if (!previousRow) {
                    return row;
                }

                return {
                    ...row,
                    invoiceNumber: previousRow.invoiceNumber ?? "",
                    amount: previousRow.amount ?? "",
                    paidAt: previousRow.paidAt ?? "",
                    invoiceFileName: previousRow.invoiceFileName ?? "",
                    paymentProofFileName: previousRow.paymentProofFileName ?? "",
                };
            });

            return [...mergedAutoRows, ...manualRows];
        });
    }, [
        isEditMode,
        form.contractRunningStartDate,
        form.contractRunningEndDate,
        form.billingPeriodMode,
        form.billingCustomEvery,
        form.billingCustomUnit,
    ]);

    const handleInvoiceRowChange = (rowKey, updates) => {
        setInvoiceRows((previousRows) =>
            previousRows.map((row) =>
                row.key === rowKey
                    ? {
                        ...row,
                        ...updates,
                    }
                    : row,
            ));
    };

    const handleAddManualInvoiceRow = () => {
        const manualKey = `manual-${Date.now()}-${Math.round(Math.random() * 1000)}`;

        setInvoiceRows((previousRows) => ([
            ...previousRows,
            {
                key: manualKey,
                kind: "manual",
                periodStartDate: form.contractRunningStartDate || "",
                periodEndDate: form.contractRunningEndDate || "",
                invoiceNumber: "",
                amount: "",
                paidAt: "",
                invoiceFileName: "",
                paymentProofFileName: "",
            },
        ]));
    };

    const handleRemoveManualInvoiceRow = (rowKey) => {
        setInvoiceRows((previousRows) =>
            previousRows.filter((row) => !(row.kind === "manual" && row.key === rowKey)));
    };

    const handleSubmit = async (event) => {
        event.preventDefault();

        const name = form.name.trim();
        const ispName = form.ispName.trim();
        const normalizedIspNames = ispName
            .split(",")
            .map((segment) => segment.trim())
            .filter(Boolean);
        const primaryIspName = normalizedIspNames[0] ?? "";
        const contractNumber = form.contractNumber.trim();
        const activationFeeAmount = Number(form.activationFeeAmount);
        const contractInitialStartDate = form.contractInitialStartDate;
        const contractRunningStartDate = form.contractRunningStartDate;
        const contractRunningEndDate = form.contractRunningEndDate;
        const contractCoreType = form.contractCoreType;
        const contractCoreTotal = Number(form.contractCoreTotal);
        const billingPeriodMode = form.billingPeriodMode;
        const billingCustomEvery = Number(form.billingCustomEvery);
        const billingCustomUnit = form.billingCustomUnit;
        const isCustomBillingMode = billingPeriodMode === "custom";
        const billingCycle = resolveBillingCycle(
            billingPeriodMode,
            form.billingCustomEvery,
            billingCustomUnit,
        );
        const contractSharingRatioLeft = form.contractSharingRatioLeft.trim();
        const contractSharingRatioRight = form.contractSharingRatioRight.trim();
        const isSharingRatioLeftValid = /^[1-9]\d*$/.test(contractSharingRatioLeft);
        const isSharingRatioRightValid = /^[1-9]\d*$/.test(contractSharingRatioRight);
        const normalizedSharingRatio = isSharingRatioLeftValid && isSharingRatioRightValid
            ? `${String(Number(contractSharingRatioLeft))}:${String(Number(contractSharingRatioRight))}`
            : "";
        const hasContractNumber = Boolean(contractNumber);
        const hasAnyContractDate = Boolean(
            contractInitialStartDate || contractRunningStartDate || contractRunningEndDate,
        );
        const hasAllContractDates = Boolean(
            contractInitialStartDate && contractRunningStartDate && contractRunningEndDate,
        );

        if (!name || !primaryIspName) {
            setSubmitError("Nama pelanggan dan nama ISP wajib diisi.");
            return;
        }

        if (!Number.isFinite(activationFeeAmount) || activationFeeAmount < 0) {
            setSubmitError("Biaya aktivasi harus berupa angka >= 0.");
            return;
        }

        if (isCustomBillingMode) {
            if (!Number.isFinite(billingCustomEvery) || billingCustomEvery <= 0) {
                setSubmitError("Periode tagihan custom harus berupa angka lebih besar dari 0.");
                return;
            }

            if (!["hari", "bulan", "tahun"].includes(billingCustomUnit)) {
                setSubmitError("Satuan periode tagihan custom tidak valid.");
                return;
            }
        }

        if (!isEditMode && hasAnyContractDate && !hasAllContractDates) {
            setSubmitError("Periode kontrak harus diisi lengkap: awal kontrak, periode berjalan awal, dan periode berjalan akhir.");
            return;
        }

        if (!isEditMode && hasContractNumber && !hasAllContractDates) {
            setSubmitError("Nomor kontrak membutuhkan periode kontrak yang lengkap.");
            return;
        }

        if (!isEditMode && hasAllContractDates && contractRunningStartDate > contractRunningEndDate) {
            setSubmitError("Tanggal periode berjalan awal tidak boleh lebih besar dari tanggal periode berjalan akhir.");
            return;
        }

        if (!isEditMode && hasAllContractDates && contractInitialStartDate > contractRunningStartDate) {
            setSubmitError("Tanggal awal kontrak tidak boleh lebih besar dari tanggal periode berjalan awal.");
            return;
        }

        if (!isEditMode && hasAllContractDates) {
            if (contractCoreType === "core" && (!Number.isFinite(contractCoreTotal) || contractCoreTotal <= 0)) {
                setSubmitError("Total core pada detail teknis harus lebih besar dari 0.");
                return;
            }

            if (contractCoreType === "sharing_core" && (!isSharingRatioLeftValid || !isSharingRatioRightValid)) {
                setSubmitError("Rasio shared core tidak valid. Gunakan format seperti 1:2 atau 3:5.");
                return;
            }
        }

        let invoiceDraftValidationError = "";
        const normalizedInvoiceDrafts = !isEditMode && hasAllContractDates
            ? invoiceRows.map((row, index) => {
                const periodStartDate = String(row.periodStartDate ?? "").trim();
                const periodEndDate = String(row.periodEndDate ?? "").trim();
                const invoiceNumber = String(row.invoiceNumber ?? "").trim();
                const amount = Number(row.amount);
                const paidAt = String(row.paidAt ?? "").trim();
                const invoiceFileName = String(row.invoiceFileName ?? "").trim();
                const paymentProofFileName = String(row.paymentProofFileName ?? "").trim();

                if (!periodStartDate || !periodEndDate) {
                    invoiceDraftValidationError = `Periode tagihan pada baris ${index + 1} wajib diisi.`;
                }

                if (!invoiceDraftValidationError && periodStartDate > periodEndDate) {
                    invoiceDraftValidationError = `Periode tagihan pada baris ${index + 1} tidak valid.`;
                }

                if (!invoiceDraftValidationError && (!Number.isFinite(amount) || amount <= 0)) {
                    invoiceDraftValidationError = `Jumlah tagihan pada baris ${index + 1} harus berupa angka > 0.`;
                }

                return {
                    periodStartDate,
                    periodEndDate,
                    invoiceNumber: invoiceNumber || undefined,
                    amount: Number.isFinite(amount) ? Math.round(Math.max(amount, 1)) : 1,
                    paidAt: paidAt || null,
                    invoiceFileUrl: invoiceFileName ? `upload://${invoiceFileName}` : null,
                    paymentProofFileUrl: paymentProofFileName
                        ? `upload://${paymentProofFileName}`
                        : null,
                };
            })
            : [];

        if (invoiceDraftValidationError) {
            setSubmitError(invoiceDraftValidationError);
            return;
        }

        if (!isEditMode && hasAllContractDates && !billingCycle) {
            setSubmitError("Periode tagihan belum valid untuk membentuk jadwal invoice.");
            return;
        }

        if (!isEditMode && hasAllContractDates && normalizedInvoiceDrafts.length === 0) {
            setSubmitError("Jadwal invoice belum terbentuk. Lengkapi periode berjalan dan periode tagihan.");
            return;
        }

        if (isEditMode && !customer?.id) {
            setSubmitError("Data pelanggan untuk edit tidak ditemukan.");
            return;
        }

        setIsSubmitting(true);
        setSubmitError("");
        setSubmitSuccess("");

        try {
            const payload = {
                name,
                ispName: primaryIspName,
                status: form.status === "nonaktif" ? "nonaktif" : "aktif",
            };

            if (normalizedIspNames.length > 1) {
                payload.newIspNames = normalizedIspNames.slice(1);
            }

            if (!isActivationFeeLocked) {
                payload.activationFeeAmount = Math.round(activationFeeAmount);
                payload.activationFeePaidAt = form.activationFeePaidAt || null;
            }

            if (!isEditMode && hasAllContractDates) {
                payload.contractStartDate = contractRunningStartDate;
                payload.contractEndDate = contractRunningEndDate;
                payload.contractCoreType = contractCoreType;
                payload.contractCoreTotal = contractCoreType === "core" ? Math.round(contractCoreTotal) : undefined;
                payload.contractSharingRatio = contractCoreType === "sharing_core" ? normalizedSharingRatio : undefined;
                payload.contractNumber = hasContractNumber ? contractNumber : undefined;
                payload.billingPeriodMode = billingPeriodMode;
                payload.billingCustomEvery = billingPeriodMode === "custom"
                    ? Math.round(Number(form.billingCustomEvery))
                    : undefined;
                payload.billingCustomUnit = billingPeriodMode === "custom" ? billingCustomUnit : undefined;
                payload.invoiceDrafts = normalizedInvoiceDrafts;
            }

            const endpoint = isEditMode
                ? `${API_BASE_URL}/api/customers/${customer.id}`
                : `${API_BASE_URL}/api/customers`;
            const method = isEditMode ? "PATCH" : "POST";

            const result = await fetchJson(endpoint, {
                method,
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify(payload),
            });

            setSubmitSuccess(
                isEditMode
                    ? "Data pelanggan berhasil diperbarui oleh admin."
                    : "Pelanggan baru berhasil ditambahkan oleh admin.",
            );

            if (onSaved) {
                await onSaved(result);
            }
        } catch (requestError) {
            setSubmitError(
                requestError instanceof Error
                    ? requestError.message
                    : "Terjadi kesalahan saat menyimpan data pelanggan.",
            );
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <AppShell activeSection="customers" onNavigate={onNavigate}>
            <form className="mx-auto w-full max-w-6xl space-y-8" onSubmit={handleSubmit}>
                <div className="flex flex-col justify-between gap-4 md:flex-row md:items-end">
                    <div>
                        <h2 className="text-3xl font-extrabold leading-tight text-blue-950 font-headline">
                            {isEditMode ? "Edit Data Pelanggan" : "Entri Pelanggan Baru"}
                        </h2>
                        <p className="mt-2 max-w-lg text-on-surface-variant">
                            Lengkapi data inti pelanggan untuk sinkronisasi arsip dan monitoring tenant.
                        </p>
                    </div>

                    <div className="flex gap-3">
                        <button
                            className="rounded-xl px-6 py-2.5 font-semibold text-on-surface-variant transition-all hover:bg-surface-container-high active:scale-95"
                            onClick={onCancel}
                            type="button"
                        >
                            Batalkan
                        </button>
                        <button
                            className="rounded-xl bg-gradient-to-br from-primary to-primary-container px-8 py-2.5 font-bold text-white shadow-lg shadow-primary/20 transition-all hover:-translate-y-0.5 hover:shadow-xl disabled:cursor-not-allowed disabled:opacity-60"
                            disabled={isSubmitting}
                            type="submit"
                        >
                            {isSubmitting
                                ? "Menyimpan..."
                                : isEditMode
                                    ? "Simpan Perubahan"
                                    : "Simpan Pelanggan"}
                        </button>
                    </div>
                </div>

                {submitError && (
                    <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm font-medium text-red-700">
                        {submitError}
                    </div>
                )}

                {submitSuccess && (
                    <div className="rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm font-medium text-emerald-700">
                        {submitSuccess}
                    </div>
                )}

                <div className="grid grid-cols-12 gap-8">
                    <div className="col-span-12 space-y-8 lg:col-span-8">
                        <section className="rounded-lg bg-surface-container-lowest p-8 shadow-sm">
                            <div className="mb-6 flex items-center gap-3">
                                <span className="material-symbols-outlined text-primary">badge</span>
                                <h3 className="text-lg font-bold text-blue-950">Identitas Pelanggan</h3>
                            </div>

                            <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
                                <div>
                                    <label className="mb-2 block text-xs font-bold uppercase tracking-wider text-on-surface-variant">
                                        Nama ISP
                                    </label>
                                    <input
                                        list={ispDatalistId}
                                        className="w-full rounded-lg border-none bg-surface p-3 text-sm focus:ring-2 focus:ring-primary/20"
                                        onChange={(event) => setForm((previous) => ({ ...previous, ispName: event.target.value }))}
                                        placeholder="Pilih ISP yang ada atau ketik ISP baru"
                                        type="text"
                                        value={form.ispName}
                                    />
                                    <datalist id={ispDatalistId}>
                                        {ispOptions.map((isp) => (
                                            <option key={isp} value={isp} />
                                        ))}
                                    </datalist>
                                    <p className="mt-1 text-[11px] text-slate-500">
                                        Bisa pilih dari daftar ISP existing atau ketik nama ISP baru.
                                    </p>
                                </div>

                                <div>
                                    <label className="mb-2 block text-xs font-bold uppercase tracking-wider text-on-surface-variant">
                                        Status Keaktifan
                                    </label>
                                    <select
                                        className="w-full rounded-lg border-none bg-surface p-3 text-sm focus:ring-2 focus:ring-primary/20"
                                        onChange={(event) => setForm((previous) => ({ ...previous, status: event.target.value }))}
                                        value={form.status}
                                    >
                                        <option value="aktif">Aktif</option>
                                        <option value="nonaktif">Non-aktif</option>
                                    </select>
                                </div>

                                <div className="md:col-span-2">
                                    <label className="mb-2 block text-xs font-bold uppercase tracking-wider text-on-surface-variant">
                                        Nama Pelanggan / Institusi
                                    </label>
                                    <input
                                        className="w-full rounded-lg border-none bg-surface p-3 text-sm focus:ring-2 focus:ring-primary/20"
                                        onChange={(event) => setForm((previous) => ({ ...previous, name: event.target.value }))}
                                        placeholder="Masukkan nama lengkap pelanggan"
                                        type="text"
                                        value={form.name}
                                    />
                                </div>
                            </div>
                        </section>

                        {!isEditMode && (
                            <section className="rounded-lg border-l-4 border-blue-900 bg-surface-container-lowest p-8 shadow-sm">
                                <div className="mb-6 flex items-center gap-3">
                                    <span className="material-symbols-outlined text-primary">calendar_today</span>
                                    <h3 className="text-lg font-bold text-blue-950">Periode Kontrak</h3>
                                </div>

                                <div className="mb-6">
                                    <label className="mb-2 block text-xs font-bold uppercase tracking-wider text-on-surface-variant">
                                        Nomor Kontrak
                                    </label>
                                    <input
                                        className="w-full rounded-lg border-none bg-surface p-3 text-sm focus:ring-2 focus:ring-primary/20"
                                        onChange={(event) => setForm((previous) => ({ ...previous, contractNumber: event.target.value }))}
                                        placeholder="Contoh: CTR-KIMA-2026-001"
                                        type="text"
                                        value={form.contractNumber}
                                    />
                                </div>

                                <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
                                    <div>
                                        <label className="mb-2 block text-xs font-bold uppercase tracking-wider text-on-surface-variant">
                                            Awal Kontrak
                                        </label>
                                        <input
                                            className="w-full rounded-lg border-none bg-surface p-3 text-sm focus:ring-2 focus:ring-primary/20"
                                            onChange={(event) => setForm((previous) => ({ ...previous, contractInitialStartDate: event.target.value }))}
                                            type="date"
                                            value={form.contractInitialStartDate}
                                        />
                                    </div>

                                    <div>
                                        <label className="mb-2 block text-xs font-bold uppercase tracking-wider text-on-surface-variant">
                                            Berjalan - Mulai
                                        </label>
                                        <input
                                            className="w-full rounded-lg border-none bg-surface p-3 text-sm focus:ring-2 focus:ring-primary/20"
                                            onChange={(event) => setForm((previous) => ({ ...previous, contractRunningStartDate: event.target.value }))}
                                            type="date"
                                            value={form.contractRunningStartDate}
                                        />
                                    </div>

                                    <div>
                                        <label className="mb-2 block text-xs font-bold uppercase tracking-wider text-on-surface-variant">
                                            Berjalan - Akhir
                                        </label>
                                        <input
                                            className="w-full rounded-lg border-none bg-surface p-3 text-sm focus:ring-2 focus:ring-primary/20"
                                            onChange={(event) => setForm((previous) => ({ ...previous, contractRunningEndDate: event.target.value }))}
                                            type="date"
                                            value={form.contractRunningEndDate}
                                        />
                                    </div>
                                </div>
                            </section>
                        )}

                        {!isEditMode && (
                            <section className="rounded-lg bg-surface-container-lowest p-8 shadow-sm">
                                <div className="mb-4 flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
                                    <div>
                                        <h3 className="text-lg font-bold text-blue-950">Rencana Invoice Awal</h3>
                                        <p className="text-xs text-on-surface-variant">
                                            Jumlah baris otomatis mengikuti periode berjalan dan periode tagihan.
                                        </p>
                                    </div>
                                    <button
                                        className="inline-flex items-center gap-1 rounded-lg bg-primary/10 px-3 py-2 text-xs font-bold text-primary transition-colors hover:bg-primary/20"
                                        onClick={handleAddManualInvoiceRow}
                                        type="button"
                                    >
                                        <span className="material-symbols-outlined text-sm">add</span>
                                        Tambah Baris Manual
                                    </button>
                                </div>

                                <div className="overflow-x-auto rounded-xl border border-slate-100 bg-white">
                                    <table className="w-full min-w-[1100px] border-collapse">
                                        <thead>
                                            <tr className="border-b border-slate-100 bg-slate-50/80">
                                                <th className="px-3 py-2 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">No</th>
                                                <th className="px-3 py-2 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Periode Tagihan</th>
                                                <th className="px-3 py-2 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Nomor Invoice</th>
                                                <th className="px-3 py-2 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Jumlah Tiap Tagihan</th>
                                                <th className="px-3 py-2 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Up Invoice</th>
                                                <th className="px-3 py-2 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Up Bukti Bayar</th>
                                                <th className="px-3 py-2 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Tanggal Dibayar</th>
                                                <th className="px-3 py-2 text-right text-[11px] font-black uppercase tracking-wider text-slate-500">Aksi</th>
                                            </tr>
                                        </thead>

                                        <tbody className="divide-y divide-slate-100">
                                            {invoiceRows.length === 0 && (
                                                <tr>
                                                    <td className="px-3 py-4 text-center text-xs text-slate-500" colSpan="8">
                                                        Isi periode berjalan dan pilih periode tagihan untuk membentuk baris invoice otomatis.
                                                    </td>
                                                </tr>
                                            )}

                                            {invoiceRows.map((row, index) => (
                                                <tr key={row.key} className="align-top hover:bg-slate-50/80">
                                                    <td className="px-3 py-2 text-xs font-semibold text-slate-600">
                                                        {String(index + 1).padStart(2, "0")}
                                                    </td>

                                                    <td className="px-3 py-2 text-xs text-slate-700">
                                                        {row.kind === "manual" ? (
                                                            <div className="grid grid-cols-2 gap-2">
                                                                <input
                                                                    className="rounded-lg border border-slate-200 bg-slate-50 px-2 py-1.5 text-xs"
                                                                    onChange={(event) =>
                                                                        handleInvoiceRowChange(row.key, {
                                                                            periodStartDate: event.target.value,
                                                                        })
                                                                    }
                                                                    type="date"
                                                                    value={row.periodStartDate}
                                                                />
                                                                <input
                                                                    className="rounded-lg border border-slate-200 bg-slate-50 px-2 py-1.5 text-xs"
                                                                    onChange={(event) =>
                                                                        handleInvoiceRowChange(row.key, {
                                                                            periodEndDate: event.target.value,
                                                                        })
                                                                    }
                                                                    type="date"
                                                                    value={row.periodEndDate}
                                                                />
                                                            </div>
                                                        ) : (
                                                            <div>
                                                                <p className="font-semibold text-slate-700">
                                                                    {formatDate(row.periodStartDate)} - {formatDate(row.periodEndDate)}
                                                                </p>
                                                                <p className="mt-1 text-[10px] font-bold uppercase tracking-wider text-primary">
                                                                    Otomatis
                                                                </p>
                                                            </div>
                                                        )}
                                                    </td>

                                                    <td className="px-3 py-2">
                                                        <input
                                                            className="w-full rounded-lg border border-slate-200 bg-slate-50 px-2 py-1.5 text-xs"
                                                            onChange={(event) =>
                                                                handleInvoiceRowChange(row.key, {
                                                                    invoiceNumber: event.target.value,
                                                                })
                                                            }
                                                            placeholder="INV-..."
                                                            type="text"
                                                            value={row.invoiceNumber}
                                                        />
                                                    </td>

                                                    <td className="px-3 py-2">
                                                        <input
                                                            className="w-full rounded-lg border border-slate-200 bg-slate-50 px-2 py-1.5 text-xs"
                                                            min="1"
                                                            onChange={(event) =>
                                                                handleInvoiceRowChange(row.key, {
                                                                    amount: event.target.value,
                                                                })
                                                            }
                                                            placeholder="0"
                                                            step="1"
                                                            type="number"
                                                            value={row.amount}
                                                        />
                                                    </td>

                                                    <td className="px-3 py-2">
                                                        <input
                                                            accept=".pdf,.jpg,.jpeg,.png,.webp"
                                                            className="w-full text-xs"
                                                            onChange={(event) =>
                                                                handleInvoiceRowChange(row.key, {
                                                                    invoiceFileName: event.target.files?.[0]?.name ?? "",
                                                                })
                                                            }
                                                            type="file"
                                                        />
                                                        {row.invoiceFileName && (
                                                            <p className="mt-1 truncate text-[10px] text-slate-500">{row.invoiceFileName}</p>
                                                        )}
                                                    </td>

                                                    <td className="px-3 py-2">
                                                        <input
                                                            accept=".pdf,.jpg,.jpeg,.png,.webp"
                                                            className="w-full text-xs"
                                                            onChange={(event) =>
                                                                handleInvoiceRowChange(row.key, {
                                                                    paymentProofFileName: event.target.files?.[0]?.name ?? "",
                                                                })
                                                            }
                                                            type="file"
                                                        />
                                                        {row.paymentProofFileName && (
                                                            <p className="mt-1 truncate text-[10px] text-slate-500">{row.paymentProofFileName}</p>
                                                        )}
                                                    </td>

                                                    <td className="px-3 py-2">
                                                        <input
                                                            className="w-full rounded-lg border border-slate-200 bg-slate-50 px-2 py-1.5 text-xs"
                                                            onChange={(event) =>
                                                                handleInvoiceRowChange(row.key, {
                                                                    paidAt: event.target.value,
                                                                })
                                                            }
                                                            type="date"
                                                            value={row.paidAt}
                                                        />
                                                    </td>

                                                    <td className="px-3 py-2 text-right">
                                                        {row.kind === "manual" ? (
                                                            <button
                                                                className="rounded-md px-2 py-1 text-[11px] font-semibold text-red-600 transition-colors hover:bg-red-50"
                                                                onClick={() => handleRemoveManualInvoiceRow(row.key)}
                                                                type="button"
                                                            >
                                                                Hapus
                                                            </button>
                                                        ) : (
                                                            <span className="text-[10px] font-semibold text-slate-400">-</span>
                                                        )}
                                                    </td>
                                                </tr>
                                            ))}
                                        </tbody>
                                    </table>
                                </div>
                            </section>
                        )}
                    </div>

                    <div className="col-span-12 space-y-8 lg:col-span-4">
                        {!isEditMode && (
                            <section className="rounded-lg bg-surface-container-low p-6">
                                <div className="mb-6 flex items-center gap-3">
                                    <span className="material-symbols-outlined text-primary">settings_ethernet</span>
                                    <h3 className="text-sm font-bold uppercase tracking-wide text-blue-950">Detail Teknis (Eksklusif)</h3>
                                </div>

                                <div className="space-y-4">
                                    <label className="block cursor-pointer">
                                        <div
                                            className={`flex items-start gap-4 rounded-xl border-2 bg-surface-container-lowest p-4 transition-all ${form.contractCoreType === "core" ? "border-primary" : "border-transparent"}`}
                                        >
                                            <input
                                                checked={form.contractCoreType === "core"}
                                                className="mt-1 text-primary focus:ring-primary"
                                                name="tech_type"
                                                onChange={() => setForm((previous) => ({ ...previous, contractCoreType: "core" }))}
                                                type="radio"
                                            />
                                            <div className="flex-1">
                                                <p className="text-sm font-bold text-blue-950">Dedicated Core</p>
                                                <p className="mb-3 text-xs text-on-surface-variant">Core eksklusif tanpa pembagian bandwidth.</p>
                                                <div className="relative">
                                                    <input
                                                        className="w-full rounded-lg border-none bg-surface p-2.5 text-xs focus:ring-2 focus:ring-primary/20"
                                                        min="1"
                                                        onChange={(event) => setForm((previous) => ({ ...previous, contractCoreTotal: event.target.value }))}
                                                        placeholder="Jumlah Core"
                                                        step="1"
                                                        type="number"
                                                        value={form.contractCoreTotal}
                                                    />
                                                    <span className="absolute right-3 top-1/2 -translate-y-1/2 text-[10px] font-bold text-slate-400">CORE</span>
                                                </div>
                                            </div>
                                        </div>
                                    </label>

                                    <label className="block cursor-pointer">
                                        <div
                                            className={`flex items-start gap-4 rounded-xl border-2 bg-surface-container-lowest p-4 transition-all ${form.contractCoreType === "sharing_core" ? "border-primary" : "border-transparent"}`}
                                        >
                                            <input
                                                checked={form.contractCoreType === "sharing_core"}
                                                className="mt-1 text-primary focus:ring-primary"
                                                name="tech_type"
                                                onChange={() => setForm((previous) => ({ ...previous, contractCoreType: "sharing_core" }))}
                                                type="radio"
                                            />
                                            <div className="flex-1">
                                                <p className="text-sm font-bold text-blue-950">Shared Core</p>
                                                <p className="mb-3 text-xs text-on-surface-variant">Core berbagi dengan rasio tertentu.</p>
                                                <div className="flex items-center gap-2">
                                                    <input
                                                        className="w-full rounded-lg border-none bg-surface p-2.5 text-xs focus:ring-2 focus:ring-primary/20"
                                                        min="1"
                                                        onChange={(event) => setForm((previous) => ({ ...previous, contractSharingRatioLeft: event.target.value }))}
                                                        placeholder="Kiri"
                                                        step="1"
                                                        type="number"
                                                        value={form.contractSharingRatioLeft}
                                                    />
                                                    <span className="text-sm font-bold text-slate-500">:</span>
                                                    <input
                                                        className="w-full rounded-lg border-none bg-surface p-2.5 text-xs focus:ring-2 focus:ring-primary/20"
                                                        min="1"
                                                        onChange={(event) => setForm((previous) => ({ ...previous, contractSharingRatioRight: event.target.value }))}
                                                        placeholder="Kanan"
                                                        step="1"
                                                        type="number"
                                                        value={form.contractSharingRatioRight}
                                                    />
                                                </div>
                                            </div>
                                        </div>
                                    </label>
                                </div>
                            </section>
                        )}

                        <section className="rounded-lg bg-surface-container-low p-6">
                            <div className="mb-6 flex items-center gap-3">
                                <span className="material-symbols-outlined text-primary">payments</span>
                                <h3 className="text-sm font-bold uppercase tracking-wide text-blue-950">Billing & Aktivasi</h3>
                            </div>

                            <div className="space-y-6">
                                <div>
                                    <label className="mb-3 block text-[10px] font-bold uppercase tracking-widest text-on-surface-variant">
                                        Periode Tagihan
                                    </label>
                                    <div className="mb-3 grid grid-cols-3 gap-2">
                                        <button
                                            className={`rounded-lg py-2 text-xs font-bold transition-colors ${form.billingPeriodMode === "bulanan"
                                                ? "bg-primary text-white"
                                                : "bg-surface-container-lowest text-on-surface-variant hover:bg-slate-200"
                                                }`}
                                            onClick={() => setForm((previous) => ({ ...previous, billingPeriodMode: "bulanan" }))}
                                            type="button"
                                        >
                                            Bulanan
                                        </button>
                                        <button
                                            className={`rounded-lg py-2 text-xs font-bold transition-colors ${form.billingPeriodMode === "3bulanan"
                                                ? "bg-primary text-white"
                                                : "bg-surface-container-lowest text-on-surface-variant hover:bg-slate-200"
                                                }`}
                                            onClick={() => setForm((previous) => ({ ...previous, billingPeriodMode: "3bulanan" }))}
                                            type="button"
                                        >
                                            3 Bulanan
                                        </button>
                                        <button
                                            className={`rounded-lg py-2 text-xs font-bold transition-colors ${form.billingPeriodMode === "custom"
                                                ? "bg-primary text-white"
                                                : "bg-surface-container-lowest text-on-surface-variant hover:bg-slate-200"
                                                }`}
                                            onClick={() => setForm((previous) => ({ ...previous, billingPeriodMode: "custom" }))}
                                            type="button"
                                        >
                                            Custom Fleksibel
                                        </button>
                                    </div>

                                    <div
                                        className={`rounded-xl p-4 transition-colors ${form.billingPeriodMode === "custom"
                                            ? "bg-surface-container-lowest"
                                            : "bg-slate-100"
                                            }`}
                                    >
                                        <p className="mb-2 text-[10px] font-bold uppercase text-on-surface-variant">Kustom Fleksibel</p>
                                        <div className="flex gap-2">
                                            <input
                                                className="w-20 rounded-lg border-none bg-surface p-2 text-xs disabled:cursor-not-allowed disabled:bg-slate-200 disabled:text-slate-500"
                                                disabled={form.billingPeriodMode !== "custom"}
                                                min="1"
                                                onChange={(event) => setForm((previous) => ({ ...previous, billingCustomEvery: event.target.value }))}
                                                placeholder="1"
                                                step="1"
                                                type="number"
                                                value={form.billingCustomEvery}
                                            />
                                            <select
                                                className="flex-1 rounded-lg border-none bg-surface p-2 text-xs disabled:cursor-not-allowed disabled:bg-slate-200 disabled:text-slate-500"
                                                disabled={form.billingPeriodMode !== "custom"}
                                                onChange={(event) => setForm((previous) => ({ ...previous, billingCustomUnit: event.target.value }))}
                                                value={form.billingCustomUnit}
                                            >
                                                <option value="hari">Hari</option>
                                                <option value="bulan">Bulan</option>
                                                <option value="tahun">Tahun</option>
                                            </select>
                                        </div>
                                        {form.billingPeriodMode !== "custom" && (
                                            <p className="mt-2 text-[10px] text-slate-500">
                                                Pilih mode Custom Fleksibel untuk mengisi periode custom.
                                            </p>
                                        )}
                                    </div>
                                </div>

                                <div className="border-t border-slate-200 pt-4">
                                    <label className="mb-3 block text-[10px] font-bold uppercase tracking-widest text-on-surface-variant">
                                        Biaya Aktivasi
                                    </label>
                                    <div className="relative">
                                        <span className="absolute left-3 top-1/2 -translate-y-1/2 text-xs font-bold text-slate-500">Rp</span>
                                        <input
                                            className="w-full rounded-lg border-none bg-surface-container-lowest py-3 pl-10 pr-4 text-sm font-bold text-blue-900 focus:ring-2 focus:ring-primary/20 disabled:cursor-not-allowed disabled:bg-slate-100 disabled:text-slate-500"
                                            disabled={isActivationFeeLocked}
                                            min="0"
                                            onChange={(event) => setForm((previous) => ({ ...previous, activationFeeAmount: event.target.value }))}
                                            placeholder="0"
                                            step="1"
                                            type="number"
                                            value={form.activationFeeAmount}
                                        />
                                    </div>
                                    <p className="mt-2 text-[10px] italic text-slate-500">* Biaya instalasi awal core dan perangkat.</p>
                                </div>

                                {isEditMode && (
                                    <div>
                                        <label className="mb-2 block text-[10px] font-bold uppercase tracking-widest text-on-surface-variant">
                                            Tanggal Bayar Aktivasi
                                        </label>
                                        <input
                                            className="w-full rounded-lg border-none bg-surface-container-lowest p-3 text-sm focus:ring-2 focus:ring-primary/20 disabled:cursor-not-allowed disabled:bg-slate-100 disabled:text-slate-500"
                                            disabled={isActivationFeeLocked}
                                            onChange={(event) => setForm((previous) => ({ ...previous, activationFeePaidAt: event.target.value }))}
                                            type="date"
                                            value={form.activationFeePaidAt}
                                        />
                                        {isActivationFeeLocked ? (
                                            <p className="mt-2 text-[11px] font-semibold text-amber-700">
                                                Biaya aktivasi sudah terbayar dan dikunci karena hanya sekali di awal sewa.
                                            </p>
                                        ) : (
                                            <p className="mt-2 text-[11px] text-slate-500">
                                                Kosongkan jika biaya aktivasi belum dibayar.
                                            </p>
                                        )}
                                    </div>
                                )}
                            </div>
                        </section>
                    </div>
                </div>
            </form>
        </AppShell>
    );
}

function CustomerDirectoryPage({
    activeSection,
    onNavigate,
    customers,
    isLoading,
    error,
    onOpenDetail,
    onOpenCreate,
    onRefresh,
}) {
    const [searchTerm, setSearchTerm] = useState("");
    const [ispFilter, setIspFilter] = useState("all");
    const [statusFilter, setStatusFilter] = useState("all");
    const [collapsedIspMap, setCollapsedIspMap] = useState({});

    const statusMeta = useMemo(() => ({
        active: {
            label: "Aktif",
            containerClass: "border-green-600 bg-surface-container text-on-surface",
            dotClass: "bg-green-600",
        },
        "non-active": {
            label: "Non-aktif",
            containerClass: "border-error bg-error-container/30 text-on-error-container",
            dotClass: "bg-error",
        },
    }), []);

    const resolveCustomerStatusKey = useCallback((customer) => {
        if (!customer.active || customer.rawStatus === "nonaktif") {
            return "non-active";
        }

        return "active";
    }, []);

    const ispOptions = useMemo(() => {
        const values = new Set();
        customers.forEach((item) => {
            if (Array.isArray(item.ispList) && item.ispList.length > 0) {
                item.ispList.forEach((ispName) => values.add(ispName));
                return;
            }

            values.add(item.isp);
        });
        return Array.from(values).sort((left, right) => left.localeCompare(right));
    }, [customers]);

    const normalizedSearch = searchTerm.trim().toLowerCase();

    const filteredCustomers = useMemo(() => {
        return customers.filter((customer) => {
            const customerStatusKey = resolveCustomerStatusKey(customer);
            const searchableIspNames = Array.isArray(customer.ispList) && customer.ispList.length > 0
                ? customer.ispList.join(" ")
                : customer.isp;
            const isInSelectedIsp = ispFilter === "all"
                ? true
                : Array.isArray(customer.ispList) && customer.ispList.length > 0
                    ? customer.ispList.includes(ispFilter)
                    : customer.isp === ispFilter;

            const matchesSearch = normalizedSearch
                ? customer.name.toLowerCase().includes(normalizedSearch)
                || searchableIspNames.toLowerCase().includes(normalizedSearch)
                || customer.customerId.toLowerCase().includes(normalizedSearch)
                : true;

            const matchesIsp = isInSelectedIsp;
            const matchesStatus = statusFilter === "all" ? true : customerStatusKey === statusFilter;

            return matchesSearch && matchesIsp && matchesStatus;
        });
    }, [customers, normalizedSearch, ispFilter, statusFilter, resolveCustomerStatusKey]);

    const groupedCustomers = useMemo(() => {
        const groups = new Map();

        filteredCustomers.forEach((customer) => {
            if (!groups.has(customer.isp)) {
                groups.set(customer.isp, []);
            }

            groups.get(customer.isp).push(customer);
        });

        return Array.from(groups.entries())
            .sort(([leftIsp], [rightIsp]) => leftIsp.localeCompare(rightIsp))
            .map(([ispName, customersByIsp]) => {
                const sortedCustomers = customersByIsp
                    .slice()
                    .sort((left, right) => left.name.localeCompare(right.name));
                const nonActiveCount = sortedCustomers.filter(
                    (customer) => resolveCustomerStatusKey(customer) === "non-active",
                ).length;

                return {
                    ispName,
                    customers: sortedCustomers,
                    totalCustomers: sortedCustomers.length,
                    nonActiveCount,
                };
            });
    }, [filteredCustomers, resolveCustomerStatusKey]);

    const totalActive = filteredCustomers.filter(
        (customer) => resolveCustomerStatusKey(customer) === "active",
    ).length;
    const totalNonActive = filteredCustomers.filter(
        (customer) => resolveCustomerStatusKey(customer) === "non-active",
    ).length;

    const isAnyFilterActive = Boolean(normalizedSearch)
        || ispFilter !== "all"
        || statusFilter !== "all";

    const highlightedText = useCallback((value) => {
        const text = String(value ?? "");
        if (!normalizedSearch) {
            return text;
        }

        const lowerText = text.toLowerCase();
        if (!lowerText.includes(normalizedSearch)) {
            return text;
        }

        const nodes = [];
        let cursor = 0;
        let keyIndex = 0;

        while (cursor < text.length) {
            const matchIndex = lowerText.indexOf(normalizedSearch, cursor);

            if (matchIndex === -1) {
                nodes.push(
                    <span key={`text-${keyIndex}`}>
                        {text.slice(cursor)}
                    </span>,
                );
                break;
            }

            if (matchIndex > cursor) {
                nodes.push(
                    <span key={`text-${keyIndex}`}>
                        {text.slice(cursor, matchIndex)}
                    </span>,
                );
                keyIndex += 1;
            }

            nodes.push(
                <mark key={`mark-${keyIndex}`} className="rounded bg-amber-100 px-0.5 text-amber-900">
                    {text.slice(matchIndex, matchIndex + normalizedSearch.length)}
                </mark>,
            );

            keyIndex += 1;
            cursor = matchIndex + normalizedSearch.length;
        }

        return nodes;
    }, [normalizedSearch]);

    const handleToggleIspGroup = (ispName) => {
        if (normalizedSearch) {
            return;
        }

        setCollapsedIspMap((previous) => ({
            ...previous,
            [ispName]: !previous[ispName],
        }));
    };

    const handleResetSearch = () => {
        setSearchTerm("");
        setIspFilter("all");
        setStatusFilter("all");
        setCollapsedIspMap({});
    };

    return (
        <AppShell activeSection={activeSection} onNavigate={onNavigate}>
            <div className="mx-auto max-w-7xl">
                <header className="mb-8 flex flex-col justify-between gap-6 md:flex-row md:items-end">
                    <div className="space-y-2">
                        <nav className="mb-1 flex items-center gap-2 text-xs font-medium text-on-surface-variant/70">
                            <span>KIMA Arsip</span>
                            <span className="material-symbols-outlined text-[10px]">chevron_right</span>
                            <span className="font-bold text-primary">Direktori Pelanggan</span>
                        </nav>
                        <h1 className="text-4xl font-extrabold tracking-tight text-primary">Daftar Pelanggan</h1>
                        <p className="max-w-xl leading-relaxed text-on-surface-variant">
                            Semua data pelanggan dikelola satu arah oleh admin: tambah, edit, update,
                            dan sinkronisasi data monitoring dilakukan dari panel ini.
                        </p>
                    </div>

                    <div className="flex flex-wrap gap-3">
                        <button
                            className="inline-flex items-center justify-center gap-2 rounded-xl bg-gradient-to-br from-primary to-primary-container px-6 py-3.5 font-bold text-white shadow-lg transition-all hover:shadow-primary/20 active:scale-95"
                            onClick={onOpenCreate}
                            type="button"
                        >
                            <span className="material-symbols-outlined">person_add</span>
                            <span>Tambah Pelanggan</span>
                        </button>
                        <button
                            className="inline-flex items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-5 py-3.5 font-bold text-slate-700 shadow-sm transition-colors hover:bg-slate-50"
                            onClick={() => {
                                void onRefresh();
                            }}
                            type="button"
                        >
                            <span className="material-symbols-outlined">sync</span>
                            <span>Refresh Data</span>
                        </button>
                    </div>
                </header>

                {error && (
                    <div className="mb-6 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm font-medium text-red-700">
                        {error}
                    </div>
                )}

                <section className="mb-6 rounded-2xl border border-blue-100 bg-blue-50/70 p-5">
                    <div className="mb-3 flex items-center gap-2">
                        <span className="material-symbols-outlined text-blue-700">info</span>
                        <p className="text-sm font-bold text-blue-800">Alur Kerja Admin</p>
                    </div>
                    <p className="text-sm leading-relaxed text-blue-700">
                        Upload dokumen, edit data pelanggan, dan pembaruan status dikelola langsung oleh admin.
                        Sistem otomatis menandai tindakan prioritas saat kontrak mendekati berakhir atau ada data yang belum lengkap.
                    </p>
                </section>

                <section className="mb-8 flex flex-wrap items-center gap-4 rounded-2xl bg-surface-container-low p-5">
                    <div className="relative min-w-[280px] flex-1">
                        <span className="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-outline">
                            search
                        </span>
                        <input
                            className="w-full rounded-xl border-none bg-surface-container-lowest py-3 pl-12 pr-4 text-sm shadow-sm focus:ring-2 focus:ring-primary/10"
                            onChange={(event) => setSearchTerm(event.target.value)}
                            placeholder="Search ISP or Customer Name"
                            type="text"
                            value={searchTerm}
                        />
                    </div>

                    <div className="relative min-w-[220px]">
                        <select
                            className="w-full appearance-none rounded-xl border-none bg-surface-container-lowest px-4 py-3 pr-10 text-sm shadow-sm focus:ring-2 focus:ring-primary/10"
                            onChange={(event) => setIspFilter(event.target.value)}
                            value={ispFilter}
                        >
                            <option value="all">Semua ISP</option>
                            {ispOptions.map((isp) => (
                                <option key={isp} value={isp}>
                                    {isp}
                                </option>
                            ))}
                        </select>
                        <span className="material-symbols-outlined pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-outline">
                            expand_more
                        </span>
                    </div>

                    <div className="relative min-w-[220px]">
                        <select
                            className="w-full appearance-none rounded-xl border-none bg-surface-container-lowest px-4 py-3 pr-10 text-sm shadow-sm focus:ring-2 focus:ring-primary/10"
                            onChange={(event) => setStatusFilter(event.target.value)}
                            value={statusFilter}
                        >
                            <option value="all">Semua Status</option>
                            <option value="active">Aktif</option>
                            <option value="non-active">Non-aktif</option>
                        </select>
                        <span className="material-symbols-outlined pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-outline">
                            expand_more
                        </span>
                    </div>

                    <button
                        className="inline-flex items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-600 shadow-sm transition-colors hover:bg-slate-50"
                        onClick={handleResetSearch}
                        type="button"
                    >
                        <span className="material-symbols-outlined text-base">restart_alt</span>
                        Reset search
                    </button>
                </section>

                <section className="mb-8 grid grid-cols-1 gap-4 md:grid-cols-3">
                    <div className="rounded-xl border border-slate-100 bg-white p-5 shadow-sm">
                        <p className="text-xs font-black uppercase tracking-widest text-on-surface-variant/60">
                            Pelanggan Ditampilkan
                        </p>
                        <p className="mt-3 text-3xl font-extrabold text-on-surface">{filteredCustomers.length}</p>
                    </div>
                    <div className="rounded-xl border border-slate-100 bg-white p-5 shadow-sm">
                        <p className="text-xs font-black uppercase tracking-widest text-on-surface-variant/60">
                            ISP Ditampilkan
                        </p>
                        <p className="mt-3 text-3xl font-extrabold text-on-surface">{groupedCustomers.length}</p>
                    </div>
                    <div className="rounded-xl border border-slate-100 bg-white p-5 shadow-sm">
                        <p className="text-xs font-black uppercase tracking-widest text-on-surface-variant/60">
                            Status Pelanggan
                        </p>
                        <p className="mt-3 text-3xl font-extrabold text-on-surface">{totalActive} / {totalNonActive}</p>
                        <p className="mt-1 text-xs text-on-surface-variant">
                            Aktif / Non-aktif
                        </p>
                    </div>
                </section>

                <section className="space-y-4">
                    {isLoading && (
                        <div className="rounded-2xl border border-slate-100 bg-white px-6 py-6 text-center text-sm text-on-surface-variant shadow-sm">
                            Memuat data pelanggan dari backend...
                        </div>
                    )}

                    {!isLoading && groupedCustomers.length === 0 && (
                        <div className="rounded-2xl border border-slate-100 bg-white px-6 py-10 text-center shadow-sm">
                            <p className="text-base font-bold text-on-surface">No results found</p>
                            <p className="mt-2 text-sm text-on-surface-variant">
                                Coba kata kunci lain atau gunakan tombol reset search.
                            </p>
                            {isAnyFilterActive && (
                                <button
                                    className="mt-4 inline-flex items-center gap-2 rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-600 transition-colors hover:bg-slate-50"
                                    onClick={handleResetSearch}
                                    type="button"
                                >
                                    <span className="material-symbols-outlined text-base">restart_alt</span>
                                    Reset search
                                </button>
                            )}
                        </div>
                    )}

                    {!isLoading && groupedCustomers.map((group) => {
                        const isExpanded = normalizedSearch ? true : !collapsedIspMap[group.ispName];

                        return (
                            <div
                                key={group.ispName}
                                className="overflow-hidden rounded-2xl border border-slate-100 bg-surface-container-lowest shadow-[0_20px_40px_rgba(25,28,30,0.04)]"
                            >
                                <button
                                    className="flex w-full items-center justify-between gap-4 bg-slate-50/50 px-6 py-4 text-left"
                                    onClick={() => handleToggleIspGroup(group.ispName)}
                                    type="button"
                                >
                                    <div>
                                        <p className="text-[10px] font-black uppercase tracking-widest text-on-surface-variant/60">
                                            ISP Group
                                        </p>
                                        <h3 className="mt-1 text-lg font-extrabold text-primary">
                                            {highlightedText(group.ispName)}
                                        </h3>
                                    </div>

                                    <div className="flex items-center gap-2">
                                        <span className="rounded-full bg-blue-100 px-2.5 py-1 text-[11px] font-bold text-blue-700">
                                            {group.totalCustomers} pelanggan
                                        </span>
                                        {group.nonActiveCount > 0 && (
                                            <span className="rounded-full bg-rose-100 px-2.5 py-1 text-[11px] font-bold text-rose-700">
                                                {group.nonActiveCount} non-aktif
                                            </span>
                                        )}
                                        <span
                                            className={`material-symbols-outlined text-slate-500 transition-transform ${isExpanded ? "rotate-180" : ""}`}
                                        >
                                            expand_more
                                        </span>
                                    </div>
                                </button>

                                <div className={`grid transition-all duration-300 ease-out ${isExpanded ? "grid-rows-[1fr] opacity-100" : "grid-rows-[0fr] opacity-0"}`}>
                                    <div className="overflow-hidden">
                                        <div className="overflow-x-auto border-t border-outline-variant/10">
                                            <table className="w-full border-collapse">
                                                <thead>
                                                    <tr className="border-b border-outline-variant/10 bg-white">
                                                        <th className="px-6 py-4 text-left text-[10px] font-black uppercase tracking-widest text-on-surface-variant/60">
                                                            Customer Name
                                                        </th>
                                                        <th className="px-6 py-4 text-left text-[10px] font-black uppercase tracking-widest text-on-surface-variant/60">
                                                            Status
                                                        </th>
                                                        <th className="px-6 py-4 text-right text-[10px] font-black uppercase tracking-widest text-on-surface-variant/60">
                                                            Aksi
                                                        </th>
                                                    </tr>
                                                </thead>

                                                <tbody className="divide-y divide-surface">
                                                    {group.customers.map((customer) => {
                                                        const customerStatusKey = resolveCustomerStatusKey(customer);
                                                        const customerStatusMeta = statusMeta[customerStatusKey];

                                                        return (
                                                            <tr key={customer.id} className="group transition-colors hover:bg-slate-50">
                                                                <td className="px-6 py-4">
                                                                    <div className="flex flex-col">
                                                                        <span className="text-sm font-semibold text-on-surface">
                                                                            {highlightedText(customer.name)}
                                                                        </span>
                                                                        <span className="mt-1 text-[11px] text-on-surface-variant">
                                                                            ID: {highlightedText(customer.customerId)}
                                                                        </span>
                                                                    </div>
                                                                </td>

                                                                <td className="px-6 py-4">
                                                                    <span
                                                                        className={`inline-flex items-center gap-2 rounded-full border-l-[4px] py-1 pl-1 pr-3 ${customerStatusMeta.containerClass}`}
                                                                    >
                                                                        <span className={`h-1.5 w-1.5 rounded-full ${customerStatusMeta.dotClass}`}></span>
                                                                        <span className="text-[11px] font-bold uppercase">
                                                                            {customerStatusMeta.label}
                                                                        </span>
                                                                    </span>
                                                                </td>

                                                                <td className="px-6 py-4 text-right">
                                                                    <button
                                                                        className="inline-flex items-center gap-1 rounded-lg bg-primary/5 px-3 py-2 text-primary transition-colors hover:bg-primary/10"
                                                                        onClick={() => onOpenDetail(customer)}
                                                                        type="button"
                                                                    >
                                                                        <span className="material-symbols-outlined text-base">visibility</span>
                                                                        Detail
                                                                    </button>
                                                                </td>
                                                            </tr>
                                                        );
                                                    })}
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        );
                    })}
                </section>
            </div>
        </AppShell>
    );
}

function MonitoringSpreadsheetPage({ activeSection, onNavigate, ispOptions, onOpenCustomerById }) {
    const currentYear = String(new Date().getUTCFullYear());
    const [filters, setFilters] = useState(() => ({
        search: "",
        year: currentYear,
        isp: "",
        status: "",
    }));
    const [appliedFilters, setAppliedFilters] = useState(() => ({
        year: currentYear,
        isp: "",
        status: "",
    }));

    const [billingRows, setBillingRows] = useState([]);
    const [billingSummary, setBillingSummary] = useState({
        lunas: 0,
        belum_bayar: 0,
        terlambat: 0,
        belum_ditagih: 0,
    });
    const [alerts, setAlerts] = useState([]);
    const [recentActivities, setRecentActivities] = useState([]);
    const [selectedInvoiceCell, setSelectedInvoiceCell] = useState(null);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState("");

    const loadMonitoring = useCallback(async () => {
        setIsLoading(true);
        setError("");

        try {
            const params = new URLSearchParams();
            params.set("year", appliedFilters.year);

            if (appliedFilters.isp) {
                params.set("isp", appliedFilters.isp);
            }

            if (appliedFilters.status) {
                params.set("status", appliedFilters.status);
            }

            const [billingResult, alertsResult] = await Promise.all([
                fetchJson(`${API_BASE_URL}/api/monitoring/billing?${params.toString()}`),
                fetchJson(`${API_BASE_URL}/api/monitoring/alerts?year=${encodeURIComponent(appliedFilters.year)}`),
            ]);

            const nextBillingRows = Array.isArray(billingResult?.rows) ? billingResult.rows : [];

            setBillingRows(nextBillingRows);
            setBillingSummary({
                lunas: Number(billingResult?.summary?.lunas ?? 0),
                belum_bayar: Number(billingResult?.summary?.belum_bayar ?? 0),
                terlambat: Number(billingResult?.summary?.terlambat ?? 0),
                belum_ditagih: Number(billingResult?.summary?.belum_ditagih ?? 0),
            });

            let nextAlerts = [];
            if (Array.isArray(alertsResult)) {
                nextAlerts = alertsResult;
            } else if (Array.isArray(alertsResult?.alerts)) {
                nextAlerts = alertsResult.alerts;
            }

            setAlerts(nextAlerts);

            const candidateCustomerIds = [
                ...new Set([
                    ...nextBillingRows.map((row) => row.customerId).filter((id) => Number.isFinite(id)),
                    ...nextAlerts.map((alert) => alert.customerId).filter((id) => Number.isFinite(id)),
                ]),
            ].slice(0, 8);

            if (candidateCustomerIds.length === 0) {
                setRecentActivities([]);
                return;
            }

            const nameMap = new Map();
            nextBillingRows.forEach((row) => {
                nameMap.set(row.customerId, row.customerName);
            });
            nextAlerts.forEach((alert) => {
                if (!nameMap.has(alert.customerId) && alert.customerName) {
                    nameMap.set(alert.customerId, alert.customerName);
                }
            });

            const timelineResults = await Promise.all(
                candidateCustomerIds.map(async (customerId) => {
                    try {
                        const timeline = await fetchJson(
                            `${API_BASE_URL}/api/customers/${customerId}/timeline`,
                        );

                        return {
                            customerId,
                            customerName: nameMap.get(customerId) ?? `Pelanggan #${customerId}`,
                            events: Array.isArray(timeline) ? timeline : [],
                        };
                    } catch {
                        return {
                            customerId,
                            customerName: nameMap.get(customerId) ?? `Pelanggan #${customerId}`,
                            events: [],
                        };
                    }
                }),
            );

            const flattenedActivities = timelineResults
                .flatMap((entry) => entry.events.map((event) => ({
                    id: `${entry.customerId}-${event.id ?? event.date ?? event.title}`,
                    customerId: entry.customerId,
                    customerName: entry.customerName,
                    title: event.title ?? "Aktivitas",
                    description: event.description ?? "-",
                    date: event.date ?? null,
                })))
                .sort((left, right) => {
                    const leftDate = parseDateValue(left.date)?.getTime() ?? 0;
                    const rightDate = parseDateValue(right.date)?.getTime() ?? 0;
                    return rightDate - leftDate;
                })
                .slice(0, 10);

            setRecentActivities(flattenedActivities);
        } catch (requestError) {
            setError(
                requestError instanceof Error
                    ? requestError.message
                    : "Terjadi kesalahan saat memuat monitoring.",
            );
        } finally {
            setIsLoading(false);
        }
    }, [appliedFilters]);

    useEffect(() => {
        void loadMonitoring();
    }, [loadMonitoring]);

    const filteredRows = useMemo(() => {
        const loweredSearch = filters.search.trim().toLowerCase();

        if (!loweredSearch) {
            return billingRows;
        }

        return billingRows.filter((row) => {
            const haystack = [
                row.customerName,
                row.ispName,
                row.customerCode,
            ]
                .filter(Boolean)
                .join(" ")
                .toLowerCase();

            return haystack.includes(loweredSearch);
        });
    }, [billingRows, filters.search]);

    const visibleSummary = useMemo(() => {
        const summary = {
            lunas: 0,
            belum_bayar: 0,
            terlambat: 0,
            belum_ditagih: 0,
        };

        filteredRows.forEach((row) => {
            if (!Array.isArray(row.months)) {
                return;
            }

            row.months.forEach((status) => {
                if (status in summary) {
                    summary[status] += 1;
                }
            });
        });

        return summary;
    }, [filteredRows]);

    const totalCells =
        visibleSummary.lunas
        + visibleSummary.belum_bayar
        + visibleSummary.terlambat
        + visibleSummary.belum_ditagih;

    const totalAlerts = alerts.length;
    const hasIssues = totalAlerts > 0;
    const issueCounts = {
        missingContract: alerts.filter((alert) => alert.code === "missing_contract").length,
        missingInvoice: alerts.filter((alert) => ["missing_invoice_current_month", "invoice_not_uploaded", "payment_overdue"].includes(alert.code)).length,
        contractExpiring: alerts.filter((alert) => ["contract_expiring", "bak_missing"].includes(alert.code)).length,
        activationFee: alerts.filter((alert) => alert.code === "activation_fee_unpaid").length,
        terminationDoc: alerts.filter((alert) => ["has_termination_document", "missing_required_document"].includes(alert.code)).length,
    };

    const actionNeededToday = useMemo(() => {
        return alerts
            .slice(0, 8)
            .map((alert) => ({
                ...alert,
                actionLabel: {
                    missing_contract: "Buka & Buat Surat Kontrak",
                    missing_invoice_current_month: "Buka & Buat Surat Invoice",
                    payment_overdue: "Buka & Follow Up Pembayaran",
                    contract_expiring: "Buka & Tindak Masa Sewa",
                    bak_missing: "Buka & Upload BAK",
                    missing_required_document: "Buka & Lengkapi Dokumen",
                    invoice_not_uploaded: "Buka & Lengkapi Invoice",
                    has_termination_document: "Buka & Verifikasi Terminasi",
                    activation_fee_unpaid: "Buka & Update Aktivasi",
                }[alert.code] ?? "Buka Detail Pelanggan",
                targetTab: {
                    missing_contract: "contracts",
                    missing_invoice_current_month: "invoices",
                    payment_overdue: "invoices",
                    contract_expiring: "contracts",
                    bak_missing: "documents",
                    missing_required_document: "documents",
                    invoice_not_uploaded: "invoices",
                    has_termination_document: "documents",
                    activation_fee_unpaid: "overview",
                }[alert.code] ?? "overview",
            }));
    }, [alerts]);

    const yearOptions = [
        String(Number(currentYear) - 1),
        currentYear,
        String(Number(currentYear) + 1),
    ];

    return (
        <AppShell activeSection={activeSection} onNavigate={onNavigate}>
            <div className="mx-auto max-w-[1450px] space-y-6">
                <section className="flex flex-col justify-between gap-4 md:flex-row md:items-end">
                    <div className="space-y-1">
                        <div className="flex items-center gap-2 text-xs font-medium uppercase tracking-wider text-slate-400">
                            <span>Dashboard</span>
                            <span className="material-symbols-outlined text-[10px]">chevron_right</span>
                            <span className="font-bold text-primary">Monitoring Operasional</span>
                        </div>
                        <h2 className="text-3xl font-extrabold tracking-tight text-blue-900">
                            Monitoring Informasi Penting
                        </h2>
                        <p className="text-sm text-on-surface-variant">
                            Seluruh informasi operasional penting ditampilkan di sini: prioritas aksi,
                            alert, aktivitas terbaru, dan matriks billing pelanggan. Monitoring bersifat
                            read-only, sedangkan edit/upload dilakukan dari Detail Pelanggan.
                        </p>
                    </div>

                    <button
                        className="inline-flex items-center gap-2 rounded-lg bg-primary px-4 py-2 font-semibold text-white shadow-md transition-opacity hover:opacity-90"
                        onClick={() => {
                            void loadMonitoring();
                        }}
                        type="button"
                    >
                        <span className="material-symbols-outlined text-sm">sync</span>
                        Refresh Monitoring
                    </button>
                </section>

                {error && (
                    <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm font-medium text-red-700">
                        {error}
                    </div>
                )}

                <section className={`rounded-xl border px-5 py-4 ${hasIssues ? "border-amber-200 bg-amber-50" : "border-emerald-200 bg-emerald-50"}`}>
                    {hasIssues ? (
                        <div className="flex items-start gap-3">
                            <span className="material-symbols-outlined text-amber-700">warning</span>
                            <div>
                                <p className="text-sm font-bold text-amber-800">Ada kendala yang butuh tindakan</p>
                                <p className="text-sm text-amber-700">
                                    Terdapat {totalAlerts} alert. Cek bagian Action Needed Today
                                    lalu buka Detail Pelanggan untuk mengedit kontrak, invoice, dokumen,
                                    atau status aktivasi.
                                </p>
                            </div>
                        </div>
                    ) : (
                        <div className="flex items-start gap-3">
                            <span className="material-symbols-outlined text-emerald-700">verified</span>
                            <div>
                                <p className="text-sm font-bold text-emerald-800">Semua aman</p>
                                <p className="text-sm text-emerald-700">
                                    Tidak ada kendala aktif. Lanjutkan pemantauan melalui mode spreadsheet dan filtering.
                                </p>
                            </div>
                        </div>
                    )}
                </section>

                <section className="space-y-4 rounded-xl border border-slate-100 bg-white p-5 shadow-sm">
                    <div className="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4">
                        <div>
                            <label className="mb-1.5 ml-1 block text-[10px] font-black uppercase tracking-widest text-slate-400">
                                Pencarian Cepat
                            </label>
                            <div className="relative">
                                <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-base text-slate-400">
                                    search
                                </span>
                                <input
                                    className="w-full rounded-lg border border-slate-200 bg-slate-50 py-2.5 pl-9 pr-4 text-xs transition-all focus:border-primary focus:ring-2 focus:ring-primary/20"
                                    onChange={(event) =>
                                        setFilters((previous) => ({
                                            ...previous,
                                            search: event.target.value,
                                        }))
                                    }
                                    placeholder="ISP, Pelanggan, Kode..."
                                    type="text"
                                    value={filters.search}
                                />
                            </div>
                        </div>

                        <div>
                            <label className="mb-1.5 ml-1 block text-[10px] font-black uppercase tracking-widest text-slate-400">
                                Nama ISP
                            </label>
                            <select
                                className="w-full rounded-lg border border-slate-200 bg-slate-50 px-3 py-2.5 text-xs font-medium text-slate-600 transition-all focus:border-primary focus:ring-2 focus:ring-primary/20"
                                onChange={(event) =>
                                    setFilters((previous) => ({
                                        ...previous,
                                        isp: event.target.value,
                                    }))
                                }
                                value={filters.isp}
                            >
                                <option value="">Semua ISP</option>
                                {ispOptions.map((isp) => (
                                    <option key={isp} value={isp}>
                                        {isp}
                                    </option>
                                ))}
                            </select>
                        </div>

                        <div>
                            <label className="mb-1.5 ml-1 block text-[10px] font-black uppercase tracking-widest text-slate-400">
                                Status Invoice
                            </label>
                            <select
                                className="w-full rounded-lg border border-slate-200 bg-slate-50 px-3 py-2.5 text-xs font-medium text-slate-600 transition-all focus:border-primary focus:ring-2 focus:ring-primary/20"
                                onChange={(event) =>
                                    setFilters((previous) => ({
                                        ...previous,
                                        status: event.target.value,
                                    }))
                                }
                                value={filters.status}
                            >
                                <option value="">Semua Status</option>
                                <option value="lunas">Lunas</option>
                                <option value="belum_bayar">Belum Bayar</option>
                                <option value="terlambat">Terlambat</option>
                                <option value="belum_ditagih">Belum Ditagih</option>
                            </select>
                        </div>

                        <div>
                            <label className="mb-1.5 ml-1 block text-[10px] font-black uppercase tracking-widest text-slate-400">
                                Tahun
                            </label>
                            <select
                                className="w-full rounded-lg border border-slate-200 bg-slate-50 px-3 py-2.5 text-xs font-medium text-slate-600 transition-all focus:border-primary focus:ring-2 focus:ring-primary/20"
                                onChange={(event) =>
                                    setFilters((previous) => ({
                                        ...previous,
                                        year: event.target.value,
                                    }))
                                }
                                value={filters.year}
                            >
                                {yearOptions.map((year) => (
                                    <option key={year} value={year}>
                                        {year}
                                    </option>
                                ))}
                            </select>
                        </div>
                    </div>

                    <div className="flex flex-wrap justify-end gap-2">
                        <button
                            className="inline-flex items-center gap-2 rounded-lg border border-blue-100 bg-blue-50 px-4 py-2.5 text-xs font-bold text-blue-700 transition-colors hover:bg-blue-100"
                            onClick={() =>
                                setAppliedFilters({
                                    year: filters.year,
                                    isp: filters.isp,
                                    status: filters.status,
                                })
                            }
                            type="button"
                        >
                            <span className="material-symbols-outlined text-sm">search</span>
                            Terapkan Filter Backend
                        </button>
                        <button
                            className="inline-flex items-center gap-2 rounded-lg border border-slate-200 bg-white px-4 py-2.5 text-xs font-bold text-slate-500 transition-colors hover:bg-slate-50"
                            onClick={() => {
                                const reset = {
                                    search: "",
                                    year: currentYear,
                                    isp: "",
                                    status: "",
                                };

                                setFilters(reset);
                                setAppliedFilters({
                                    year: currentYear,
                                    isp: "",
                                    status: "",
                                });
                            }}
                            type="button"
                        >
                            <span className="material-symbols-outlined text-sm">restart_alt</span>
                            Reset
                        </button>
                    </div>
                </section>

                {hasIssues && (
                    <>
                        <section className="grid grid-cols-1 gap-6 xl:grid-cols-5">
                            <div className="xl:col-span-3 rounded-xl border border-slate-100 bg-white p-6 shadow-sm">
                                <div className="mb-4 flex items-center justify-between gap-3">
                                    <div>
                                        <p className="text-xs font-black uppercase tracking-widest text-primary">Action Needed Today</p>
                                        <h3 className="text-lg font-bold text-on-surface">Prioritas Operasional</h3>
                                    </div>
                                    <span className="rounded-full bg-blue-50 px-3 py-1 text-xs font-bold text-blue-700">
                                        {actionNeededToday.length} aksi
                                    </span>
                                </div>

                                <div className="space-y-3">
                                    {actionNeededToday.length === 0 && (
                                        <p className="rounded-lg bg-slate-50 px-4 py-3 text-sm text-on-surface-variant">
                                            Tidak ada prioritas aksi untuk saat ini.
                                        </p>
                                    )}

                                    {actionNeededToday.map((item, index) => (
                                        <div
                                            key={`${item.customerId}-${item.code}-${index}`}
                                            className="flex flex-col gap-3 rounded-lg border border-slate-100 bg-slate-50/70 px-4 py-3 md:flex-row md:items-center md:justify-between"
                                        >
                                            <div>
                                                <p className="text-sm font-bold text-on-surface">{item.customerName ?? `Pelanggan #${item.customerId}`}</p>
                                                <p className="mt-1 text-xs text-on-surface-variant">{item.message}</p>
                                            </div>

                                            <button
                                                className="inline-flex items-center gap-1 self-start rounded-lg bg-primary/10 px-3 py-2 text-xs font-bold text-primary transition-colors hover:bg-primary/15"
                                                onClick={() => onOpenCustomerById(item.customerId, item.targetTab)}
                                                type="button"
                                            >
                                                <span className="material-symbols-outlined text-sm">bolt</span>
                                                {item.actionLabel}
                                            </button>
                                        </div>
                                    ))}
                                </div>
                            </div>

                            <div className="xl:col-span-2 rounded-xl border border-slate-100 bg-white p-6 shadow-sm">
                                <div className="mb-4">
                                    <p className="text-xs font-black uppercase tracking-widest text-primary">Ringkasan Cepat</p>
                                    <h3 className="text-lg font-bold text-on-surface">Ringkasan Alert</h3>
                                </div>

                                <div className="space-y-3">
                                    <IssueCountRow label="Surat kontrak belum dibuat" value={issueCounts.missingContract} />
                                    <IssueCountRow label="Surat invoice bulan ini belum dibuat" value={issueCounts.missingInvoice} />
                                    <IssueCountRow label="Kontrak mendekati habis" value={issueCounts.contractExpiring} />
                                    <IssueCountRow label="Biaya aktivasi belum dibayar" value={issueCounts.activationFee} />
                                    <IssueCountRow label="Dokumen terminasi terdeteksi" value={issueCounts.terminationDoc} />
                                </div>
                            </div>
                        </section>

                        <section className="rounded-xl border border-slate-100 bg-white p-6 shadow-sm">
                            <div className="mb-4 flex items-center justify-between gap-3">
                                <h3 className="text-lg font-bold text-on-surface">Recent Activity</h3>
                                <span className="text-xs font-bold uppercase tracking-widest text-on-surface-variant">
                                    Aktivitas lintas pelanggan
                                </span>
                            </div>

                            <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
                                {recentActivities.length === 0 && (
                                    <p className="rounded-lg bg-slate-50 px-4 py-3 text-sm text-on-surface-variant md:col-span-2">
                                        Aktivitas terbaru belum tersedia.
                                    </p>
                                )}

                                {recentActivities.map((activity) => (
                                    <div
                                        key={activity.id}
                                        className="rounded-lg border border-slate-100 bg-slate-50/70 px-4 py-3"
                                    >
                                        <div className="mb-1 flex items-center justify-between gap-2">
                                            <p className="text-sm font-bold text-on-surface">{activity.customerName}</p>
                                            <p className="text-[11px] font-medium text-on-surface-variant">
                                                {formatDateTime(activity.date)}
                                            </p>
                                        </div>
                                        <p className="text-sm font-semibold text-primary">{activity.title}</p>
                                        <p className="text-xs text-on-surface-variant">{activity.description}</p>
                                    </div>
                                ))}
                            </div>
                        </section>
                    </>
                )}

                <section className="flex flex-wrap items-center gap-6 rounded-xl border border-slate-100 bg-surface-container-low p-4">
                    <span className="text-[10px] font-black uppercase tracking-widest text-slate-400">Keterangan:</span>
                    <div className="flex items-center gap-2">
                        <div className="h-3 w-3 rounded bg-emerald-500"></div>
                        <span className="text-xs font-bold text-slate-600">Lunas</span>
                    </div>
                    <div className="flex items-center gap-2">
                        <div className="h-3 w-3 rounded bg-red-500"></div>
                        <span className="text-xs font-bold text-slate-600">Belum Bayar</span>
                    </div>
                    <div className="flex items-center gap-2">
                        <div className="h-3 w-3 rounded bg-orange-400"></div>
                        <span className="text-xs font-bold text-slate-600">Terlambat</span>
                    </div>
                    <div className="flex items-center gap-2">
                        <div className="h-3 w-3 rounded bg-amber-200"></div>
                        <span className="text-xs font-bold text-slate-600">Belum Ditagih</span>
                    </div>
                    <span className="text-xs font-medium text-slate-500">
                        Klik sel bulanan untuk lihat detail invoice pelanggan.
                    </span>
                    <span className="text-xs font-medium text-slate-500">
                        Biaya aktivasi: "Selesai" jika sudah dibayar, nominal jika masih outstanding.
                    </span>
                    <span className="text-xs font-medium text-slate-500">
                        Monitoring hanya menampilkan notifikasi. Edit dilakukan di Detail Pelanggan.
                    </span>
                </section>

                <section className="overflow-hidden rounded-xl border border-slate-100 bg-white shadow-sm">
                    <div className="overflow-x-auto no-scrollbar">
                        <table className="w-full min-w-[1720px] border-collapse text-[13px]">
                            <thead>
                                <tr className="border-b border-slate-100 bg-slate-50/80">
                                    <th className="w-[64px] px-4 py-5 text-left font-bold uppercase tracking-tighter text-blue-900">
                                        No
                                    </th>
                                    <th className="w-[160px] px-4 py-5 text-left font-bold uppercase tracking-tighter text-blue-900">
                                        Nama ISP
                                    </th>
                                    <th className="w-[260px] px-4 py-5 text-left font-bold uppercase tracking-tighter text-blue-900">
                                        Nama Pelanggan
                                    </th>
                                    <th className="w-[150px] px-4 py-5 text-left font-bold uppercase tracking-tighter text-blue-900">
                                        Kode
                                    </th>
                                    <th className="w-[240px] px-4 py-5 text-left font-bold uppercase tracking-tighter text-blue-900">
                                        Periode Berjalan
                                    </th>
                                    <th className="w-[180px] px-4 py-5 text-left font-bold uppercase tracking-tighter text-blue-900">
                                        Core / Sharing Core
                                    </th>
                                    <th className="w-[160px] px-4 py-5 text-left font-bold uppercase tracking-tighter text-blue-900">
                                        Sisa Masa Sewa
                                    </th>
                                    <th className="w-[120px] px-4 py-5 text-left font-bold uppercase tracking-tighter text-blue-900">
                                        Status
                                    </th>
                                    <th className="w-[170px] px-4 py-5 text-left font-bold uppercase tracking-tighter text-blue-900">
                                        Biaya Aktivasi
                                    </th>
                                    <th className="border-l border-slate-200/60 px-6 py-5 text-center font-bold uppercase tracking-widest text-blue-900" colSpan="12">
                                        Monitoring Billing {appliedFilters.year}
                                    </th>
                                </tr>
                                <tr className="border-b border-slate-100 bg-slate-100/30 text-[10px] font-black uppercase text-slate-500">
                                    <th className="border-r border-slate-200/60 bg-white" colSpan="9"></th>
                                    {monitoringMonths.map((month, index) => (
                                        <th
                                            key={month}
                                            className={`w-12 px-2 py-2 text-center ${index === 0 ? "border-l border-slate-200/60" : ""}`}
                                        >
                                            {month}
                                        </th>
                                    ))}
                                </tr>
                            </thead>

                            <tbody className="divide-y divide-slate-50">
                                {isLoading && (
                                    <tr>
                                        <td className="px-6 py-6 text-center text-sm text-slate-500" colSpan="21">
                                            Memuat data monitoring dari backend...
                                        </td>
                                    </tr>
                                )}

                                {!isLoading && filteredRows.length === 0 && (
                                    <tr>
                                        <td className="px-6 py-6 text-center text-sm text-slate-500" colSpan="21">
                                            Tidak ada data monitoring yang sesuai dengan filter.
                                        </td>
                                    </tr>
                                )}

                                {!isLoading && filteredRows.map((row, rowIndex) => (
                                    <tr key={`${row.customerId}-${rowIndex}`} className="bg-white transition-colors hover:bg-blue-50/30">
                                        <td className="px-4 py-4 font-medium text-slate-400">
                                            {String(rowIndex + 1).padStart(2, "0")}
                                        </td>
                                        <td className="px-4 py-4 font-bold text-blue-900">
                                            {row.ispName}
                                        </td>
                                        <td className="px-4 py-4">
                                            <p className="font-semibold text-slate-700">{row.customerName}</p>
                                            <button
                                                className="mt-1 inline-flex items-center gap-1 text-[11px] font-bold text-primary hover:underline"
                                                onClick={() => onOpenCustomerById(row.customerId, "overview")}
                                                type="button"
                                            >
                                                <span className="material-symbols-outlined text-sm">open_in_new</span>
                                                Buka Detail Pelanggan
                                            </button>
                                        </td>
                                        <td className="px-4 py-4 text-slate-600">{row.customerCode}</td>
                                        <td className="px-4 py-4 text-slate-600">{formatContractPeriod(row.contractStart, row.contractEnd)}</td>
                                        <td className="px-4 py-4 text-slate-600">{formatCoreAllocation(row.coreType, row.coreTotal, row.sharingRatio)}</td>
                                        <td className="px-4 py-4">
                                            {(() => {
                                                const remainingDays = getRemainingRentalDays(row.contractEnd);

                                                if (remainingDays === null) {
                                                    return <span className="text-slate-500">-</span>;
                                                }

                                                if (remainingDays < 0) {
                                                    return <span className="font-semibold text-red-700">Sudah berakhir {Math.abs(remainingDays)} hari</span>;
                                                }

                                                if (remainingDays === 0) {
                                                    return <span className="font-semibold text-amber-700">Berakhir hari ini</span>;
                                                }

                                                return <span className="font-semibold text-blue-700">{remainingDays} hari lagi</span>;
                                            })()}
                                        </td>
                                        <td className="px-4 py-4">
                                            <span className={`rounded px-2 py-0.5 text-[11px] font-bold ${row.customerStatus === "aktif" ? "bg-blue-100 text-blue-700" : "bg-slate-100 text-slate-600"}`}>
                                                {toTitleCase(row.customerStatus)}
                                            </span>
                                        </td>
                                        <td className="px-4 py-4">
                                            {row.activationFeePaidAt ? (
                                                <div>
                                                    <span className="inline-flex rounded-full bg-emerald-100 px-2 py-0.5 text-[11px] font-bold text-emerald-700">
                                                        Selesai
                                                    </span>
                                                    <p className="mt-1 text-[11px] text-slate-500">{formatDate(row.activationFeePaidAt)}</p>
                                                </div>
                                            ) : (
                                                <span className="text-xs font-bold text-amber-700">
                                                    {formatCurrency(row.activationFeeAmount)}
                                                </span>
                                            )}
                                        </td>

                                        {monitoringMonths.map((month, monthIndex) => {
                                            const status = Array.isArray(row.months)
                                                ? row.months[monthIndex]
                                                : "belum_ditagih";

                                            return (
                                                <td
                                                    key={`${row.customerId}-${month}`}
                                                    className={`p-1 ${monthIndex === 0 ? "border-l border-slate-100" : ""}`}
                                                >
                                                    <button
                                                        className={`h-8 w-full rounded-sm shadow-inner transition hover:scale-[1.02] ${getMonthStatusClass(status)}`}
                                                        onClick={() =>
                                                            setSelectedInvoiceCell({
                                                                customerId: row.customerId,
                                                                customerName: row.customerName,
                                                                customerCode: row.customerCode,
                                                                ispName: row.ispName,
                                                                month,
                                                                monthIndex,
                                                                status,
                                                                year: appliedFilters.year,
                                                                contractStart: row.contractStart,
                                                                contractEnd: row.contractEnd,
                                                                coreType: row.coreType,
                                                                coreTotal: row.coreTotal,
                                                                sharingRatio: row.sharingRatio,
                                                            })
                                                        }
                                                        title={invoiceStatusLabelMap[status] ?? status}
                                                        type="button"
                                                    >
                                                        <span className="sr-only">
                                                            {row.customerName} {month} {appliedFilters.year} {invoiceStatusLabelMap[status] ?? status}
                                                        </span>
                                                    </button>
                                                </td>
                                            );
                                        })}
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>

                    <div className="flex flex-wrap items-center justify-between gap-3 border-t border-slate-100 bg-slate-50/50 px-8 py-5">
                        <p className="text-xs font-semibold text-slate-500">
                            Menampilkan <span className="text-blue-900">{filteredRows.length}</span> baris data
                        </p>
                        <p className="text-xs font-semibold text-slate-500">
                            Total sel status: <span className="text-blue-900">{totalCells}</span>
                        </p>
                    </div>
                </section>

                <section className="grid grid-cols-1 gap-6 md:grid-cols-4">
                    <div className="rounded-xl border border-slate-100 border-l-4 border-l-emerald-500 bg-white p-6 shadow-sm">
                        <h4 className="mb-1 text-xs font-bold uppercase tracking-wider text-slate-500">
                            Lunas
                        </h4>
                        <p className="text-2xl font-black text-blue-900">{visibleSummary.lunas}</p>
                    </div>

                    <div className="rounded-xl border border-slate-100 border-l-4 border-l-red-500 bg-white p-6 shadow-sm">
                        <h4 className="mb-1 text-xs font-bold uppercase tracking-wider text-slate-500">
                            Belum Bayar
                        </h4>
                        <p className="text-2xl font-black text-blue-900">{visibleSummary.belum_bayar}</p>
                    </div>

                    <div className="rounded-xl border border-slate-100 border-l-4 border-l-orange-500 bg-white p-6 shadow-sm">
                        <h4 className="mb-1 text-xs font-bold uppercase tracking-wider text-slate-500">
                            Terlambat
                        </h4>
                        <p className="text-2xl font-black text-blue-900">{visibleSummary.terlambat}</p>
                    </div>

                    <div className="rounded-xl border border-slate-100 border-l-4 border-l-primary bg-white p-6 shadow-sm">
                        <h4 className="mb-1 text-xs font-bold uppercase tracking-wider text-slate-500">
                            Monitoring Alerts
                        </h4>
                        <p className="text-2xl font-black text-blue-900">{alerts.length}</p>
                    </div>
                </section>

                {hasIssues && (
                    <section className="rounded-xl border border-slate-100 bg-white p-6 shadow-sm">
                        <div className="mb-4 flex items-center justify-between">
                            <h3 className="text-lg font-bold text-on-surface">Alert Monitoring Detail</h3>
                            <span className="text-xs font-bold uppercase tracking-wider text-on-surface-variant">
                                Endpoint /api/monitoring/alerts
                            </span>
                        </div>

                        {alerts.length === 0 ? (
                            <p className="rounded-lg bg-surface-container-low px-4 py-3 text-sm text-on-surface-variant">
                                Tidak ada alert untuk tahun {appliedFilters.year}.
                            </p>
                        ) : (
                            <div className="space-y-3">
                                {alerts.map((alert, index) => (
                                    <div
                                        key={`${alert.customerId}-${alert.code}-${index}`}
                                        className="rounded-lg border border-slate-200 bg-slate-50 px-4 py-3 text-slate-700"
                                    >
                                        <div className="mb-1 flex items-center justify-between gap-3">
                                            <p className="text-sm font-bold">{alert.customerName}</p>
                                            <span className="rounded-full border border-current px-2 py-0.5 text-[10px] font-black uppercase tracking-wider">
                                                Butuh tindakan
                                            </span>
                                        </div>
                                        <p className="text-xs">{alert.message}</p>
                                        <button
                                            className="mt-3 inline-flex items-center gap-1 rounded-lg bg-white/70 px-3 py-1.5 text-[11px] font-bold transition-colors hover:bg-white"
                                            onClick={() =>
                                                onOpenCustomerById(
                                                    alert.customerId,
                                                    {
                                                        missing_contract: "contracts",
                                                        missing_invoice_current_month: "invoices",
                                                        payment_overdue: "invoices",
                                                        contract_expiring: "contracts",
                                                        bak_missing: "documents",
                                                        missing_required_document: "documents",
                                                        invoice_not_uploaded: "invoices",
                                                        has_termination_document: "documents",
                                                        activation_fee_unpaid: "overview",
                                                    }[alert.code] ?? "overview",
                                                )
                                            }
                                            type="button"
                                        >
                                            <span className="material-symbols-outlined text-sm">open_in_new</span>
                                            Buka Detail Pelanggan
                                        </button>
                                    </div>
                                ))}
                            </div>
                        )}
                    </section>
                )}

                <section className="rounded-xl border border-slate-100 bg-surface-container-low p-4 text-xs text-on-surface-variant">
                    Ringkasan backend (tanpa filter pencarian lokal): Lunas {billingSummary.lunas}, Belum Bayar {billingSummary.belum_bayar},
                    Terlambat {billingSummary.terlambat}, Belum Ditagih {billingSummary.belum_ditagih}.
                </section>

                {selectedInvoiceCell && (
                    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/20 px-4">
                        <div className="w-full max-w-xl rounded-2xl border border-slate-100 bg-white p-6 shadow-2xl">
                            <div className="mb-4 flex items-start justify-between gap-4">
                                <div>
                                    <p className="text-xs font-black uppercase tracking-widest text-primary">Invoice Detail (Read Only)</p>
                                    <h3 className="text-xl font-bold text-on-surface">
                                        {selectedInvoiceCell.customerName}
                                    </h3>
                                    <p className="text-xs text-on-surface-variant">
                                        {selectedInvoiceCell.ispName} | {selectedInvoiceCell.customerCode}
                                    </p>
                                </div>

                                <button
                                    className="rounded-lg bg-slate-100 p-2 text-slate-500 transition-colors hover:bg-slate-200"
                                    onClick={() => setSelectedInvoiceCell(null)}
                                    type="button"
                                >
                                    <span className="material-symbols-outlined text-base">close</span>
                                </button>
                            </div>

                            <dl className="grid grid-cols-1 gap-3 rounded-xl bg-slate-50 p-4 text-sm md:grid-cols-2">
                                <div>
                                    <dt className="text-xs uppercase tracking-wide text-slate-500">Periode</dt>
                                    <dd className="font-semibold text-slate-700">
                                        {selectedInvoiceCell.month} {selectedInvoiceCell.year}
                                    </dd>
                                </div>
                                <div>
                                    <dt className="text-xs uppercase tracking-wide text-slate-500">Status Invoice</dt>
                                    <dd className="font-semibold text-slate-700">
                                        {invoiceStatusLabelMap[selectedInvoiceCell.status] ?? toTitleCase(selectedInvoiceCell.status)}
                                    </dd>
                                </div>
                                <div>
                                    <dt className="text-xs uppercase tracking-wide text-slate-500">Kontrak Mulai</dt>
                                    <dd className="font-semibold text-slate-700">{formatDate(selectedInvoiceCell.contractStart)}</dd>
                                </div>
                                <div>
                                    <dt className="text-xs uppercase tracking-wide text-slate-500">Kontrak Berakhir</dt>
                                    <dd className="font-semibold text-slate-700">{formatDate(selectedInvoiceCell.contractEnd)}</dd>
                                </div>
                                <div>
                                    <dt className="text-xs uppercase tracking-wide text-slate-500">Core / Sharing Core</dt>
                                    <dd className="font-semibold text-slate-700">
                                        {formatCoreAllocation(selectedInvoiceCell.coreType, selectedInvoiceCell.coreTotal, selectedInvoiceCell.sharingRatio)}
                                    </dd>
                                </div>
                                <div>
                                    <dt className="text-xs uppercase tracking-wide text-slate-500">Sisa Masa Sewa</dt>
                                    <dd className="font-semibold text-slate-700">
                                        {(() => {
                                            const remainingDays = getRemainingRentalDays(selectedInvoiceCell.contractEnd);

                                            if (remainingDays === null) {
                                                return "-";
                                            }

                                            if (remainingDays < 0) {
                                                return `Sudah berakhir ${Math.abs(remainingDays)} hari`;
                                            }

                                            if (remainingDays === 0) {
                                                return "Berakhir hari ini";
                                            }

                                            return `${remainingDays} hari lagi`;
                                        })()}
                                    </dd>
                                </div>
                            </dl>

                            <p className="mt-4 text-xs text-on-surface-variant">
                                Monitoring bersifat non-edit. Gunakan detail pelanggan untuk meninjau data kontrak,
                                invoice, dan dokumen secara terpusat.
                            </p>

                            <div className="mt-5 flex flex-wrap justify-end gap-2">
                                <button
                                    className="rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-600 transition-colors hover:bg-slate-50"
                                    onClick={() => setSelectedInvoiceCell(null)}
                                    type="button"
                                >
                                    Tutup
                                </button>
                                <button
                                    className="inline-flex items-center gap-1 rounded-lg bg-primary px-4 py-2 text-sm font-semibold text-white transition-opacity hover:opacity-90"
                                    onClick={() => {
                                        onOpenCustomerById(selectedInvoiceCell.customerId, "invoices");
                                        setSelectedInvoiceCell(null);
                                    }}
                                    type="button"
                                >
                                    <span className="material-symbols-outlined text-sm">open_in_new</span>
                                    Buka Detail Pelanggan
                                </button>
                            </div>
                        </div>
                    </div>
                )}
            </div>
        </AppShell>
    );
}

function SectionPlaceholderPage({ activeSection, onNavigate }) {
    const section = sectionMeta[activeSection] ?? sectionMeta.dashboard;
    const isTrashSection = activeSection === "trash";

    return (
        <AppShell activeSection={activeSection} onNavigate={onNavigate}>
            <div className="mx-auto max-w-5xl">
                <header className="mb-10">
                    <h1 className="text-4xl font-extrabold tracking-tight text-primary">{section.title}</h1>
                    <p className="mt-3 max-w-2xl text-on-surface-variant">{section.description}</p>
                </header>

                <section className="rounded-2xl border border-slate-100 bg-surface-container-lowest p-8 shadow-sm">
                    <div className="mb-6 flex items-center gap-3">
                        <span className="material-symbols-outlined rounded-lg bg-primary/10 p-2 text-primary">
                            {isTrashSection ? "delete" : "construction"}
                        </span>
                        <div>
                            <h2 className="text-lg font-bold text-on-surface">
                                {isTrashSection
                                    ? "Antrian Pemulihan"
                                    : "Modul Disiapkan"}
                            </h2>
                            <p className="text-sm text-on-surface-variant">
                                {isTrashSection
                                    ? "Tempat sampah dipakai untuk item terhapus sementara sebelum proses pembersihan permanen."
                                    : `Untuk modul ${section.title.toLowerCase()}, endpoint backend final belum tersedia.`}
                            </p>
                        </div>
                    </div>

                    <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
                        <div className="rounded-xl bg-surface-container-low p-4">
                            <p className="text-xs font-bold uppercase tracking-widest text-primary">Status UI</p>
                            <p className="mt-2 text-sm text-on-surface">
                                {isTrashSection
                                    ? "Mode read-only pendukung workflow"
                                    : "Sudah siap dipasang data"}
                            </p>
                        </div>
                        <div className="rounded-xl bg-surface-container-low p-4">
                            <p className="text-xs font-bold uppercase tracking-widest text-primary">Backend</p>
                            <p className="mt-2 text-sm text-on-surface">Menunggu endpoint write/list final</p>
                        </div>
                        <div className="rounded-xl bg-surface-container-low p-4">
                            <p className="text-xs font-bold uppercase tracking-widest text-primary">Temporary UX</p>
                            <p className="mt-2 text-sm text-on-surface">Arahkan workflow ke modul aktif</p>
                        </div>
                    </div>

                    <button
                        className="mt-8 inline-flex items-center gap-2 rounded-xl bg-gradient-to-br from-primary to-primary-container px-5 py-3 text-sm font-bold text-white"
                        onClick={() => onNavigate("customers")}
                        type="button"
                    >
                        <span className="material-symbols-outlined text-sm">groups</span>
                        Kembali ke Direktori Pelanggan
                    </button>
                </section>
            </div>
        </AppShell>
    );
}

function CustomerDetailPage({
    customer,
    initialTab = "overview",
    onBack,
    onEdit,
    onNavigate,
    onRefreshCustomers,
}) {
    const backendCustomerId = customer.id;

    const [activeTab, setActiveTab] = useState("overview");
    const [customerDetail, setCustomerDetail] = useState(null);
    const [complianceStatus, setComplianceStatus] = useState(null);
    const [timeline, setTimeline] = useState([]);
    const [isLoadingDetail, setIsLoadingDetail] = useState(false);
    const [detailError, setDetailError] = useState("");

    const [documents, setDocuments] = useState([]);
    const [documentFilter, setDocumentFilter] = useState("all");
    const [isLoadingDocuments, setIsLoadingDocuments] = useState(false);
    const [documentsError, setDocumentsError] = useState("");
    const [uploadFeedback, setUploadFeedback] = useState("");
    const [isUploadingDocument, setIsUploadingDocument] = useState(false);
    const [newDocument, setNewDocument] = useState(() => createDefaultDocumentForm());
    const [invoiceUploadDraft, setInvoiceUploadDraft] = useState(null);
    const [invoiceUploadError, setInvoiceUploadError] = useState("");
    const [invoiceUploadFeedback, setInvoiceUploadFeedback] = useState("");
    const [isUploadingInvoiceDocument, setIsUploadingInvoiceDocument] = useState(false);
    const [contractEditor, setContractEditor] = useState(null);
    const [contractEditorError, setContractEditorError] = useState("");
    const [contractActionFeedback, setContractActionFeedback] = useState("");
    const [isSubmittingContractEditor, setIsSubmittingContractEditor] = useState(false);

    const loadCustomerDetail = useCallback(async () => {
        setIsLoadingDetail(true);
        setDetailError("");

        try {
            const [detailResult, complianceResult, timelineResult] = await Promise.all([
                fetchJson(`${API_BASE_URL}/api/customers/${backendCustomerId}`),
                fetchJson(`${API_BASE_URL}/api/customers/${backendCustomerId}/compliance-status`),
                fetchJson(`${API_BASE_URL}/api/customers/${backendCustomerId}/timeline`),
            ]);

            setCustomerDetail(detailResult ?? null);
            setComplianceStatus(complianceResult ?? null);
            setTimeline(Array.isArray(timelineResult) ? timelineResult : []);
        } catch (requestError) {
            setDetailError(
                requestError instanceof Error
                    ? requestError.message
                    : "Terjadi kesalahan saat memuat detail pelanggan.",
            );
        } finally {
            setIsLoadingDetail(false);
        }
    }, [backendCustomerId]);

    const loadDocuments = useCallback(
        async (overrideFilter) => {
            const effectiveFilter = overrideFilter ?? documentFilter;
            const filterQuery =
                effectiveFilter === "all"
                    ? ""
                    : `?jenisDokumen=${encodeURIComponent(effectiveFilter)}`;

            setIsLoadingDocuments(true);
            setDocumentsError("");

            try {
                const result = await fetchJson(
                    `${API_BASE_URL}/api/customers/${backendCustomerId}/documents${filterQuery}`,
                );

                const filteredDocuments = Array.isArray(result)
                    ? result.filter((document) => document.jenisDokumen !== "invoice")
                    : [];
                setDocuments(filteredDocuments);
            } catch (requestError) {
                setDocumentsError(
                    requestError instanceof Error
                        ? requestError.message
                        : "Terjadi kesalahan saat memuat dokumen.",
                );
            } finally {
                setIsLoadingDocuments(false);
            }
        },
        [backendCustomerId, documentFilter],
    );

    useEffect(() => {
        setActiveTab(initialTab);
        setDocumentFilter("all");
        setDocuments([]);
        setDocumentsError("");
        setUploadFeedback("");
        setInvoiceUploadDraft(null);
        setInvoiceUploadError("");
        setInvoiceUploadFeedback("");
        setContractEditor(null);
        setContractEditorError("");
        setContractActionFeedback("");
        setNewDocument(createDefaultDocumentForm());
        void loadCustomerDetail();
    }, [backendCustomerId, initialTab, loadCustomerDetail]);

    useEffect(() => {
        if (activeTab !== "documents") {
            return;
        }

        void loadDocuments();
    }, [activeTab, loadDocuments]);

    const customerName = customerDetail?.name ?? customer.name;
    const detailIspNames = Array.isArray(customerDetail?.isps)
        ? customerDetail.isps
            .map((item) => item?.name)
            .filter((name) => typeof name === "string" && name.trim().length > 0)
        : [];
    const fallbackIspNames = Array.isArray(customer?.ispList) && customer.ispList.length > 0
        ? customer.ispList
        : [customer?.isp].filter(Boolean);
    const customerIspList = detailIspNames.length > 0 ? detailIspNames : fallbackIspNames;
    const customerIsp = customerIspList.length > 0 ? customerIspList.join(", ") : "-";
    const customerStatus = customerDetail?.status ?? customer.rawStatus;
    const isActive = customerStatus === "aktif";
    const activationFeeAmount = Number(
        customerDetail?.activationFeeAmount ?? customer.activationFeeAmount ?? 0,
    );
    const activationFeePaidAt =
        customerDetail?.activationFeePaidAt ?? customer.activationFeePaidAt ?? null;
    const isActivationFeePaid = Boolean(activationFeePaidAt);
    const editableCustomer = {
        ...customer,
        name: customerName,
        isp: customerIsp,
        ispList: customerIspList,
        rawStatus: customerStatus,
        activationFeeAmount,
        activationFeePaidAt,
    };

    const contracts = Array.isArray(customerDetail?.contracts)
        ? customerDetail.contracts
        : [];
    const sortedContracts = contracts
        .slice()
        .sort((left, right) => {
            const leftCreatedAt = parseDateValue(left.createdAt)?.getTime() ?? 0;
            const rightCreatedAt = parseDateValue(right.createdAt)?.getTime() ?? 0;

            if (leftCreatedAt !== rightCreatedAt) {
                return rightCreatedAt - leftCreatedAt;
            }

            return Number(right.id ?? 0) - Number(left.id ?? 0);
        });
    const activeContract = sortedContracts.find((contract) => contract.status === "aktif") ?? null;
    const latestContractNumber = sortedContracts[0]?.contractNumber ?? "-";
    const activeContractTechnical = activeContract
        ? formatCoreAllocation(
            activeContract.coreType,
            activeContract.coreTotal,
            activeContract.sharingRatio,
        )
        : "-";
    const activeContractBillingCycle = activeContract?.billingEvery && activeContract?.billingUnit
        ? `Setiap ${activeContract.billingEvery} ${toTitleCase(activeContract.billingUnit)}`
        : "-";
    const invoices = Array.isArray(customerDetail?.invoices)
        ? customerDetail.invoices
        : [];
    const latestDocuments = (Array.isArray(customerDetail?.latestDocuments)
        ? customerDetail.latestDocuments
        : []).filter((document) => document.jenisDokumen !== "invoice");

    const warnings = Array.isArray(complianceStatus?.warnings)
        ? complianceStatus.warnings
        : [];

    const outstandingAmount = invoices.reduce((sum, invoice) => {
        if (invoice.status === "lunas") {
            return sum;
        }

        return sum + Number(invoice.amount ?? 0);
    }, 0);

    const handleRefreshAll = async () => {
        await loadCustomerDetail();

        if (onRefreshCustomers) {
            await onRefreshCustomers();
        }

        if (activeTab === "documents") {
            await loadDocuments();
        }
    };

    const handleOpenCreateContractEditor = () => {
        const startDate = new Date();
        startDate.setUTCHours(0, 0, 0, 0);
        const endDate = new Date(startDate);
        endDate.setUTCFullYear(endDate.getUTCFullYear() + 1);

        setContractEditor({
            mode: "create",
            contractId: null,
            contractNumber: "",
            startDate: startDate.toISOString().slice(0, 10),
            endDate: endDate.toISOString().slice(0, 10),
            status: "aktif",
        });
        setContractEditorError("");
    };

    const handleOpenEditContractEditor = (contract) => {
        setContractEditor({
            mode: "edit",
            contractId: contract.id,
            contractNumber: contract.contractNumber ?? "",
            startDate: contract.startDate ? String(contract.startDate).slice(0, 10) : "",
            endDate: contract.endDate ? String(contract.endDate).slice(0, 10) : "",
            status: contract.status ?? "aktif",
        });
        setContractEditorError("");
    };

    const handleSubmitContractEditor = async (event) => {
        event.preventDefault();

        if (!contractEditor) {
            return;
        }

        const startDate = String(contractEditor.startDate ?? "").trim();
        const endDate = String(contractEditor.endDate ?? "").trim();
        const contractNumber = String(contractEditor.contractNumber ?? "").trim();
        const status = String(contractEditor.status ?? "").trim();

        if (!startDate || !endDate) {
            setContractEditorError("Periode awal dan periode akhir wajib diisi.");
            return;
        }

        if (startDate > endDate) {
            setContractEditorError("Periode awal tidak boleh lebih besar dari periode akhir.");
            return;
        }

        if (contractEditor.mode === "edit") {
            if (!contractNumber) {
                setContractEditorError("Nomor kontrak wajib diisi saat edit.");
                return;
            }

            if (!["aktif", "expired", "terminated"].includes(status)) {
                setContractEditorError("Status kontrak tidak valid.");
                return;
            }
        }

        setIsSubmittingContractEditor(true);
        setContractEditorError("");

        try {
            if (contractEditor.mode === "create") {
                await fetchJson(`${API_BASE_URL}/api/customers/${backendCustomerId}/contracts`, {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                    },
                    body: JSON.stringify({
                        contractNumber: contractNumber || undefined,
                        startDate,
                        endDate,
                    }),
                });

                setContractActionFeedback("Versi kontrak baru berhasil ditambahkan.");
            } else {
                await fetchJson(
                    `${API_BASE_URL}/api/customers/${backendCustomerId}/contracts/${contractEditor.contractId}`,
                    {
                        method: "PATCH",
                        headers: {
                            "Content-Type": "application/json",
                        },
                        body: JSON.stringify({
                            contractNumber,
                            startDate,
                            endDate,
                            status,
                        }),
                    },
                );

                setContractActionFeedback("Data kontrak berhasil diperbarui.");
            }

            setContractEditor(null);
            await loadCustomerDetail();

            if (onRefreshCustomers) {
                await onRefreshCustomers();
            }
        } catch (requestError) {
            setContractEditorError(
                requestError instanceof Error
                    ? requestError.message
                    : "Terjadi kesalahan saat menyimpan data kontrak.",
            );
        } finally {
            setIsSubmittingContractEditor(false);
        }
    };

    const handleUploadDocument = async (event) => {
        event.preventDefault();

        if (!newDocument.jenisDokumen || !newDocument.tanggalDokumen) {
            setDocumentsError("Tipe dokumen dan tanggal wajib diisi.");
            return;
        }

        setIsUploadingDocument(true);
        setDocumentsError("");
        setUploadFeedback("");

        try {
            const result = await fetchJson(`${API_BASE_URL}/api/customers/${backendCustomerId}/documents`, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({
                    jenisDokumen: newDocument.jenisDokumen,
                    nomorDokumen: newDocument.nomorDokumen.trim() || undefined,
                    tanggalDokumen: newDocument.tanggalDokumen,
                    contractId: newDocument.contractId ? Number(newDocument.contractId) : undefined,
                }),
            });

            const automationNotes = Array.isArray(result?.automation?.actions) && result.automation.actions.length > 0
                ? result.automation.actions.join(" ")
                : "Dokumen berhasil diunggah.";

            setUploadFeedback(automationNotes);
            setNewDocument(createDefaultDocumentForm());
            await loadDocuments();
            await loadCustomerDetail();

            if (onRefreshCustomers) {
                await onRefreshCustomers();
            }
        } catch (requestError) {
            setDocumentsError(
                requestError instanceof Error
                    ? requestError.message
                    : "Terjadi kesalahan saat upload dokumen.",
            );
        } finally {
            setIsUploadingDocument(false);
        }
    };

    const handleOpenInvoiceUpload = (invoice) => {
        setInvoiceUploadError("");
        setInvoiceUploadFeedback("");
        setInvoiceUploadDraft({
            invoiceId: invoice.id,
            invoiceNumber: invoice.invoiceNumber ?? "",
            tanggalDokumen: `${invoice.periodYear}-${String(invoice.periodMonth).padStart(2, "0")}-01`,
            contractId: invoice.contractId ?? null,
        });
    };

    const handleSubmitInvoiceUpload = async (event) => {
        event.preventDefault();

        if (!invoiceUploadDraft) {
            return;
        }

        if (!invoiceUploadDraft.invoiceNumber.trim()) {
            setInvoiceUploadError("Nomor invoice wajib diisi sebelum upload.");
            return;
        }

        if (!invoiceUploadDraft.tanggalDokumen) {
            setInvoiceUploadError("Tanggal invoice wajib diisi.");
            return;
        }

        setIsUploadingInvoiceDocument(true);
        setInvoiceUploadError("");

        try {
            const result = await fetchJson(`${API_BASE_URL}/api/customers/${backendCustomerId}/documents`, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({
                    jenisDokumen: "invoice",
                    nomorDokumen: invoiceUploadDraft.invoiceNumber.trim(),
                    tanggalDokumen: invoiceUploadDraft.tanggalDokumen,
                    contractId: invoiceUploadDraft.contractId ?? undefined,
                }),
            });

            const automationNotes = Array.isArray(result?.automation?.actions) && result.automation.actions.length > 0
                ? result.automation.actions.join(" ")
                : "Invoice berhasil diunggah.";

            setInvoiceUploadFeedback(automationNotes);
            setInvoiceUploadDraft(null);
            await loadCustomerDetail();

            if (onRefreshCustomers) {
                await onRefreshCustomers();
            }
        } catch (requestError) {
            setInvoiceUploadError(
                requestError instanceof Error
                    ? requestError.message
                    : "Terjadi kesalahan saat upload invoice.",
            );
        } finally {
            setIsUploadingInvoiceDocument(false);
        }
    };

    const handleDeleteDocument = async (documentId) => {
        const shouldDelete = window.confirm("Hapus dokumen ini?");
        if (!shouldDelete) {
            return;
        }

        setDocumentsError("");

        try {
            await fetchJson(
                `${API_BASE_URL}/api/customers/${backendCustomerId}/documents/${documentId}`,
                { method: "DELETE" },
            );

            await loadDocuments();
            await loadCustomerDetail();

            if (onRefreshCustomers) {
                await onRefreshCustomers();
            }
        } catch (requestError) {
            setDocumentsError(
                requestError instanceof Error
                    ? requestError.message
                    : "Terjadi kesalahan saat menghapus dokumen.",
            );
        }
    };

    const getTabClassName = (tabKey) =>
        activeTab === tabKey
            ? "whitespace-nowrap border-b-2 border-primary pb-4 text-sm font-bold text-primary transition-all"
            : "whitespace-nowrap pb-4 text-sm font-medium text-on-surface-variant transition-all hover:text-primary";

    return (
        <AppShell activeSection="customers" onNavigate={onNavigate}>
            <button
                className="mb-6 inline-flex items-center gap-2 rounded-lg bg-surface-container-low px-4 py-2 text-sm font-semibold text-primary transition-colors hover:bg-surface-container"
                onClick={onBack}
                type="button"
            >
                <span className="material-symbols-outlined text-base">arrow_back</span>
                Kembali ke Daftar Pelanggan
            </button>

            <section className="mb-8 rounded-2xl bg-surface-container-lowest p-6 shadow-sm">
                <div className="flex flex-col justify-between gap-6 lg:flex-row lg:items-center">
                    <div className="flex gap-5">
                        <div className="flex h-20 w-20 items-center justify-center rounded-2xl bg-primary-fixed">
                            <span
                                className="material-symbols-outlined text-4xl text-primary"
                                style={{ fontVariationSettings: "'FILL' 1" }}
                            >
                                corporate_fare
                            </span>
                        </div>
                        <div>
                            <div className="mb-1 flex flex-wrap items-center gap-3">
                                <h2 className="text-3xl font-extrabold tracking-tight text-primary">{customerName}</h2>
                                <span
                                    className={`rounded-full border-l-4 px-3 py-1 text-xs font-bold ${isActive
                                        ? "border-primary bg-surface-container text-primary"
                                        : "border-error bg-error-container text-on-error-container"
                                        }`}
                                >
                                    {isActive ? "AKTIF" : "NON-AKTIF"}
                                </span>
                            </div>
                            <p className="text-sm text-on-surface-variant">ISP: {customerIsp}</p>
                            <p className="text-sm text-on-surface-variant">Nomor Kontrak Terbaru: {latestContractNumber}</p>
                            <p className="text-sm text-on-surface-variant">Teknis: {activeContractTechnical}</p>
                            <p className="text-sm text-on-surface-variant">Bayar: {activeContractBillingCycle}</p>
                        </div>
                    </div>

                    <div className="flex flex-wrap gap-3">
                        <button
                            className="rounded-xl bg-surface-container-high px-5 py-2.5 text-sm font-semibold text-on-surface"
                            onClick={() => {
                                void handleRefreshAll();
                            }}
                            type="button"
                        >
                            Refresh Detail
                        </button>
                        <button
                            className="inline-flex items-center gap-2 rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm font-semibold text-slate-700 transition-colors hover:bg-slate-50"
                            onClick={() => onEdit?.(editableCustomer)}
                            type="button"
                        >
                            <span className="material-symbols-outlined text-base">edit</span>
                            Edit Profil
                        </button>
                    </div>
                </div>
            </section>

            {detailError && (
                <div className="mb-6 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm font-medium text-red-700">
                    {detailError}
                </div>
            )}

            <div className="no-scrollbar mb-8 flex gap-8 overflow-x-auto border-b border-surface-container">
                <button
                    className={getTabClassName("overview")}
                    onClick={() => setActiveTab("overview")}
                    type="button"
                >
                    Ringkasan
                </button>
                <button
                    className={getTabClassName("contracts")}
                    onClick={() => setActiveTab("contracts")}
                    type="button"
                >
                    Kontrak
                </button>
                <button
                    className={getTabClassName("invoices")}
                    onClick={() => setActiveTab("invoices")}
                    type="button"
                >
                    Invoice
                </button>
                <button
                    className={getTabClassName("documents")}
                    onClick={() => setActiveTab("documents")}
                    type="button"
                >
                    Dokumen
                </button>
                <button
                    className={getTabClassName("timeline")}
                    onClick={() => setActiveTab("timeline")}
                    type="button"
                >
                    Timeline
                </button>
            </div>

            {isLoadingDetail && !customerDetail && activeTab !== "documents" && (
                <div className="mb-6 rounded-lg border border-blue-200 bg-blue-50 px-4 py-3 text-sm font-medium text-blue-700">
                    Memuat detail pelanggan...
                </div>
            )}

            {activeTab === "overview" && (
                <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
                    <section className="space-y-6 xl:col-span-2">
                        <div className="rounded-xl bg-surface-container-lowest p-6 shadow-sm">
                            <h3 className="mb-4 text-lg font-bold text-primary">Status Compliance</h3>
                            <div className="space-y-3">
                                <ComplianceItem
                                    active={Boolean(complianceStatus?.hasContract)}
                                    label="Kontrak aktif tersedia"
                                />
                                <ComplianceItem
                                    active={Boolean(complianceStatus?.hasInvoiceCurrentMonth)}
                                    label="Invoice bulan berjalan tersedia"
                                />
                                <ComplianceItem
                                    active={!complianceStatus?.contractExpiringIn30Days}
                                    label="Kontrak tidak mendekati jatuh tempo 30 hari"
                                />
                                <ComplianceItem
                                    active={!complianceStatus?.hasTerminationDocument}
                                    label="Tidak ada dokumen pemutusan"
                                />
                                <ComplianceItem
                                    active={Boolean(complianceStatus?.hasActivationFeePaid)}
                                    label="Biaya aktivasi sudah dibayar"
                                />
                            </div>

                            {warnings.length > 0 && (
                                <div className="mt-5 rounded-lg border border-amber-200 bg-amber-50 p-4">
                                    <p className="mb-2 text-xs font-black uppercase tracking-widest text-amber-700">
                                        Warning
                                    </p>
                                    <ul className="space-y-2 text-sm text-amber-800">
                                        {warnings.map((warning) => (
                                            <li key={warning} className="flex gap-2">
                                                <span className="material-symbols-outlined text-base">warning</span>
                                                <span>{warning}</span>
                                            </li>
                                        ))}
                                    </ul>
                                </div>
                            )}
                        </div>

                        <div className="rounded-xl bg-surface-container-lowest p-6 shadow-sm">
                            <h3 className="mb-4 text-lg font-bold text-primary">Dokumen Terbaru</h3>
                            {latestDocuments.length === 0 ? (
                                <p className="rounded-lg bg-surface-container-low px-4 py-3 text-sm text-on-surface-variant">
                                    Belum ada dokumen terbaru untuk pelanggan ini.
                                </p>
                            ) : (
                                <div className="space-y-3">
                                    {latestDocuments.map((document) => (
                                        <div
                                            key={document.id}
                                            className="flex flex-col gap-2 rounded-lg bg-surface-container-low px-4 py-3 md:flex-row md:items-center md:justify-between"
                                        >
                                            <div>
                                                <span
                                                    className={`mb-1 inline-block rounded-full px-2.5 py-1 text-[11px] font-bold ${documentTypeBadgeClass[document.jenisDokumen] ?? "bg-slate-100 text-slate-700"}`}
                                                >
                                                    {documentTypeLabelMap[document.jenisDokumen] ?? document.jenisDokumen}
                                                </span>
                                                <p className="text-sm font-semibold text-on-surface">
                                                    {document.nomorDokumen || "Tanpa nomor dokumen"}
                                                </p>
                                                <p className="text-xs text-on-surface-variant">
                                                    {formatDate(document.tanggalDokumen)}
                                                </p>
                                            </div>
                                            {isExternalFileUrl(document.fileUrl) ? (
                                                <a
                                                    className="inline-flex items-center gap-1 text-sm font-semibold text-primary hover:underline"
                                                    href={document.fileUrl}
                                                    rel="noreferrer"
                                                    target="_blank"
                                                >
                                                    <span className="material-symbols-outlined text-base">open_in_new</span>
                                                    Buka File
                                                </a>
                                            ) : (
                                                <span className="inline-flex items-center gap-1 text-sm font-semibold text-slate-500">
                                                    <span className="material-symbols-outlined text-base">folder</span>
                                                    Arsip Internal
                                                </span>
                                            )}
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>
                    </section>

                    <section className="space-y-6">
                        <div className="rounded-xl bg-primary-container p-6 text-white shadow-md">
                            <p className="mb-2 text-xs font-medium uppercase tracking-widest opacity-80">
                                Kontrak Berjalan
                            </p>
                            {activeContract ? (
                                <>
                                    <h4 className="text-lg font-extrabold">
                                        {activeContract.contractNumber || `Kontrak #${activeContract.id}`}
                                    </h4>
                                    <p className="mt-1 text-xs font-semibold text-blue-100">
                                        Periode awal: {formatDate(activeContract.startDate)}
                                    </p>
                                    <p className="mt-1 text-xs font-semibold text-blue-100">
                                        Periode akhir: {formatDate(activeContract.endDate)}
                                    </p>
                                    <p className="mt-1 text-xs font-semibold text-blue-100">
                                        Teknis: {activeContractTechnical}
                                    </p>
                                    <p className="mt-1 text-xs font-semibold text-blue-100">
                                        Bayar: {activeContractBillingCycle}
                                    </p>
                                </>
                            ) : (
                                <h4 className="text-base font-extrabold">Tidak ada kontrak aktif</h4>
                            )}
                        </div>

                        <div className="rounded-xl bg-secondary-container/40 p-6 shadow-sm">
                            <p className="mb-2 text-xs font-medium uppercase tracking-widest text-on-secondary-container">
                                Total Invoice
                            </p>
                            <h4 className="text-3xl font-extrabold text-on-secondary-container">{invoices.length}</h4>
                        </div>

                        <div className="rounded-xl bg-slate-100 p-6 shadow-sm">
                            <p className="mb-2 text-xs font-medium uppercase tracking-widest text-slate-600">
                                Biaya Aktivasi
                            </p>
                            {isActivationFeePaid ? (
                                <>
                                    <h4 className="text-xl font-extrabold text-emerald-700">Selesai</h4>
                                    <p className="mt-1 text-xs font-semibold text-slate-600">
                                        Tgl bayar: {formatDate(activationFeePaidAt)}
                                    </p>
                                </>
                            ) : (
                                <h4 className="text-xl font-extrabold text-amber-700">
                                    {formatCurrency(activationFeeAmount)}
                                </h4>
                            )}
                        </div>

                        <div className="rounded-xl bg-error-container/50 p-6 shadow-sm">
                            <p className="mb-2 text-xs font-medium uppercase tracking-widest text-on-error-container">
                                Potensi Outstanding
                            </p>
                            <h4 className="text-xl font-extrabold text-on-error-container">
                                {formatCurrency(outstandingAmount)}
                            </h4>
                        </div>

                        <div className="rounded-xl border border-slate-100 bg-surface-container-lowest p-6 shadow-sm">
                            <div className="mb-4 flex items-center justify-between">
                                <h4 className="font-bold text-on-surface">Aktivitas Terbaru</h4>
                                <button
                                    className="text-xs font-semibold text-primary hover:underline"
                                    onClick={() => setActiveTab("timeline")}
                                    type="button"
                                >
                                    Lihat semua
                                </button>
                            </div>

                            {timeline.length === 0 ? (
                                <p className="text-sm text-on-surface-variant">Belum ada timeline aktivitas.</p>
                            ) : (
                                <div className="space-y-3">
                                    {timeline.slice(0, 3).map((event) => (
                                        <div key={event.id} className="rounded-lg bg-surface-container-low p-3">
                                            <p className="text-xs font-black uppercase tracking-wider text-on-surface-variant">
                                                {formatDate(event.date)}
                                            </p>
                                            <p className="mt-1 text-sm font-semibold text-on-surface">{event.title}</p>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>
                    </section>
                </div>
            )}

            {activeTab === "contracts" && (
                <div className="space-y-4">
                    <div className="flex flex-col gap-3 rounded-xl bg-surface-container-lowest p-4 shadow-sm md:flex-row md:items-center md:justify-between">
                        <p className="text-sm text-on-surface-variant">
                            Baris kontrak dapat ditambah manual. Kontrak terbaru otomatis tampil di baris paling atas.
                        </p>
                        <button
                            className="inline-flex items-center gap-2 rounded-lg bg-primary px-4 py-2 text-sm font-semibold text-white transition-opacity hover:opacity-90"
                            onClick={handleOpenCreateContractEditor}
                            type="button"
                        >
                            <span className="material-symbols-outlined text-base">add</span>
                            Tambah Baris Kontrak
                        </button>
                    </div>

                    {contractActionFeedback && (
                        <div className="rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm font-medium text-emerald-700">
                            {contractActionFeedback}
                        </div>
                    )}

                    <section className="overflow-hidden rounded-xl border border-slate-100 bg-white shadow-sm">
                        <div className="overflow-x-auto">
                            <table className="w-full min-w-[900px] border-collapse">
                                <thead>
                                    <tr className="border-b border-slate-100 bg-slate-50/80">
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">
                                            No
                                        </th>
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">
                                            Nomor Kontrak
                                        </th>
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">
                                            Status
                                        </th>
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">
                                            Periode Awal
                                        </th>
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">
                                            Periode Akhir
                                        </th>
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">
                                            Dibuat
                                        </th>
                                        <th className="px-4 py-3 text-right text-[11px] font-black uppercase tracking-wider text-slate-500">
                                            Aksi
                                        </th>
                                    </tr>
                                </thead>

                                <tbody className="divide-y divide-slate-100">
                                    {sortedContracts.length === 0 && (
                                        <tr>
                                            <td className="px-4 py-6 text-center text-sm text-slate-500" colSpan="7">
                                                Belum ada data kontrak.
                                            </td>
                                        </tr>
                                    )}

                                    {sortedContracts.map((contract, index) => (
                                        <tr key={contract.id} className="hover:bg-slate-50/80">
                                            <td className="px-4 py-3 text-sm text-slate-700">
                                                {String(index + 1).padStart(2, "0")}
                                            </td>
                                            <td className="px-4 py-3 text-sm font-semibold text-slate-700">
                                                {contract.contractNumber || `#${contract.id}`}
                                            </td>
                                            <td className="px-4 py-3">
                                                <span className={`rounded-full px-2.5 py-1 text-[11px] font-bold ${contractStatusBadgeClass[contract.status] ?? "bg-slate-100 text-slate-700"}`}>
                                                    {contractStatusLabelMap[contract.status] ?? contract.status}
                                                </span>
                                            </td>
                                            <td className="px-4 py-3 text-sm text-slate-700">{formatDate(contract.startDate)}</td>
                                            <td className="px-4 py-3 text-sm text-slate-700">{formatDate(contract.endDate)}</td>
                                            <td className="px-4 py-3 text-sm text-slate-700">{formatDateTime(contract.createdAt)}</td>
                                            <td className="px-4 py-3 text-right">
                                                <button
                                                    className="inline-flex items-center gap-1 rounded-lg bg-primary/10 px-3 py-1.5 text-xs font-bold text-primary transition-colors hover:bg-primary/15"
                                                    onClick={() => handleOpenEditContractEditor(contract)}
                                                    type="button"
                                                >
                                                    <span className="material-symbols-outlined text-sm">edit</span>
                                                    Edit
                                                </button>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </section>
                </div>
            )}

            {activeTab === "invoices" && (
                <section className="space-y-4">
                    <p className="rounded-lg border border-blue-100 bg-blue-50 px-4 py-3 text-sm text-blue-700">
                        Upload invoice dilakukan per baris periode di tab ini. Upload invoice tidak perlu dari tab Dokumen.
                    </p>

                    {invoiceUploadError && (
                        <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm font-medium text-red-700">
                            {invoiceUploadError}
                        </div>
                    )}

                    {invoiceUploadFeedback && (
                        <div className="rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm font-medium text-emerald-700">
                            {invoiceUploadFeedback}
                        </div>
                    )}

                    <section className="overflow-hidden rounded-xl border border-slate-100 bg-white shadow-sm">
                        <div className="overflow-x-auto">
                            <table className="w-full min-w-[1120px] border-collapse">
                                <thead>
                                    <tr className="border-b border-slate-100 bg-slate-50/80">
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">
                                            No
                                        </th>
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">
                                            Nomor Invoice
                                        </th>
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">
                                            Periode
                                        </th>
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">
                                            Jumlah
                                        </th>
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">
                                            Status
                                        </th>
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">
                                            Dokumen
                                        </th>
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">
                                            Diperbarui
                                        </th>
                                        <th className="px-4 py-3 text-right text-[11px] font-black uppercase tracking-wider text-slate-500">
                                            Aksi
                                        </th>
                                    </tr>
                                </thead>

                                <tbody className="divide-y divide-slate-100">
                                    {invoices.length === 0 && (
                                        <tr>
                                            <td className="px-4 py-6 text-center text-sm text-slate-500" colSpan="8">
                                                Belum ada data invoice.
                                            </td>
                                        </tr>
                                    )}

                                    {invoices.map((invoice, index) => (
                                        <tr key={invoice.id} className="hover:bg-slate-50/80">
                                            <td className="px-4 py-3 text-sm text-slate-700">
                                                {String(index + 1).padStart(2, "0")}
                                            </td>
                                            <td className="px-4 py-3 text-sm font-semibold text-slate-700">
                                                {invoice.invoiceNumber || "-"}
                                            </td>
                                            <td className="px-4 py-3 text-sm text-slate-700">
                                                {monthNames[invoice.periodMonth] ?? invoice.periodMonth} {invoice.periodYear}
                                            </td>
                                            <td className="px-4 py-3 text-sm font-semibold text-slate-700">
                                                {formatCurrency(invoice.amount)}
                                            </td>
                                            <td className="px-4 py-3">
                                                <span className={`rounded-full px-2.5 py-1 text-[11px] font-bold ${invoiceStatusBadgeClass[invoice.status] ?? "bg-slate-100 text-slate-700"}`}>
                                                    {invoiceStatusLabelMap[invoice.status] ?? invoice.status}
                                                </span>
                                            </td>
                                            <td className="px-4 py-3 text-sm text-slate-700">
                                                {invoice.documentId ? `Dokumen #${invoice.documentId}` : "-"}
                                            </td>
                                            <td className="px-4 py-3 text-sm text-slate-700">{formatDateTime(invoice.updatedAt)}</td>
                                            <td className="px-4 py-3 text-right">
                                                <button
                                                    className="inline-flex items-center gap-1 rounded-lg bg-primary/10 px-3 py-2 text-xs font-bold text-primary transition-colors hover:bg-primary/15"
                                                    onClick={() => handleOpenInvoiceUpload(invoice)}
                                                    type="button"
                                                >
                                                    <span className="material-symbols-outlined text-sm">upload</span>
                                                    {invoice.documentId ? "Update Invoice" : "Upload Invoice"}
                                                </button>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </section>
                </section>
            )}

            {activeTab === "timeline" && (
                <section className="rounded-xl bg-surface-container-lowest p-6 shadow-sm">
                    <h3 className="mb-6 text-lg font-bold text-primary">Timeline Aktivitas Pelanggan</h3>

                    {timeline.length === 0 ? (
                        <p className="rounded-lg bg-surface-container-low px-4 py-3 text-sm text-on-surface-variant">
                            Belum ada aktivitas timeline.
                        </p>
                    ) : (
                        <div className="relative space-y-6 before:absolute before:bottom-0 before:left-5 before:top-0 before:w-0.5 before:bg-surface-container">
                            {timeline.map((event) => (
                                <div key={event.id} className="relative flex items-start gap-4">
                                    <div className={`relative z-10 flex h-10 w-10 items-center justify-center rounded-full ${timelineColorMap[event.type] ?? "bg-slate-100 text-slate-600"}`}>
                                        <span className="material-symbols-outlined text-base">
                                            {timelineIconMap[event.type] ?? "history"}
                                        </span>
                                    </div>
                                    <div className="rounded-lg bg-surface-container-low p-4 flex-1">
                                        <p className="text-xs font-black uppercase tracking-widest text-on-surface-variant">
                                            {formatDate(event.date)}
                                        </p>
                                        <p className="mt-1 text-sm font-bold text-on-surface">{event.title}</p>
                                        <p className="mt-1 text-sm text-on-surface-variant">{event.description}</p>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </section>
            )}

            {activeTab === "documents" && (
                <section className="space-y-6">
                    <div className="flex flex-col gap-4 rounded-xl bg-surface-container-lowest p-6 shadow-sm md:flex-row md:items-end md:justify-between">
                        <div>
                            <h3 className="text-xl font-bold text-primary">Dokumen Pelanggan</h3>
                            <p className="mt-1 text-sm text-on-surface-variant">
                                Upload dokumen non-invoice akan memicu automasi backend untuk kontrak dan status pelanggan.
                            </p>
                        </div>

                        <div className="flex w-full flex-col gap-3 sm:w-auto sm:flex-row">
                            <select
                                className="rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm"
                                onChange={(event) => {
                                    const nextFilter = event.target.value;
                                    setDocumentFilter(nextFilter);
                                    if (activeTab === "documents") {
                                        void loadDocuments(nextFilter);
                                    }
                                }}
                                value={documentFilter}
                            >
                                <option value="all">Semua Jenis</option>
                                {documentTypeOptions.map((option) => (
                                    <option key={option.value} value={option.value}>
                                        {option.label}
                                    </option>
                                ))}
                            </select>

                            <button
                                className="rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-600 transition-colors hover:bg-slate-50"
                                onClick={() => {
                                    void loadDocuments();
                                }}
                                type="button"
                            >
                                Refresh
                            </button>
                        </div>
                    </div>

                    <form
                        className="grid grid-cols-1 gap-4 rounded-xl border border-slate-100 bg-white p-6 shadow-sm lg:grid-cols-4"
                        onSubmit={handleUploadDocument}
                    >
                        <div>
                            <label className="mb-1 block text-xs font-bold uppercase tracking-wider text-on-surface-variant">
                                Jenis Dokumen
                            </label>
                            <select
                                className="w-full rounded-lg border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm"
                                onChange={(event) =>
                                    setNewDocument((previous) => ({
                                        ...previous,
                                        jenisDokumen: event.target.value,
                                    }))
                                }
                                value={newDocument.jenisDokumen}
                            >
                                {documentTypeOptions.map((option) => (
                                    <option key={option.value} value={option.value}>
                                        {option.label}
                                    </option>
                                ))}
                            </select>
                        </div>

                        <div>
                            <label className="mb-1 block text-xs font-bold uppercase tracking-wider text-on-surface-variant">
                                Nomor Dokumen
                            </label>
                            <input
                                className="w-full rounded-lg border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm"
                                onChange={(event) =>
                                    setNewDocument((previous) => ({
                                        ...previous,
                                        nomorDokumen: event.target.value,
                                    }))
                                }
                                placeholder="Opsional"
                                type="text"
                                value={newDocument.nomorDokumen}
                            />
                        </div>

                        <div>
                            <label className="mb-1 block text-xs font-bold uppercase tracking-wider text-on-surface-variant">
                                Tanggal Dokumen
                            </label>
                            <input
                                className="w-full rounded-lg border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm"
                                onChange={(event) =>
                                    setNewDocument((previous) => ({
                                        ...previous,
                                        tanggalDokumen: event.target.value,
                                    }))
                                }
                                type="date"
                                value={newDocument.tanggalDokumen}
                            />
                        </div>

                        <div>
                            <label className="mb-1 block text-xs font-bold uppercase tracking-wider text-on-surface-variant">
                                Kontrak
                            </label>
                            <select
                                className="w-full rounded-lg border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm"
                                onChange={(event) =>
                                    setNewDocument((previous) => ({
                                        ...previous,
                                        contractId: event.target.value,
                                    }))
                                }
                                value={newDocument.contractId}
                            >
                                <option value="">Tanpa Kontrak</option>
                                {contracts.map((contract) => (
                                    <option key={contract.id} value={String(contract.id)}>
                                        #{contract.id} ({formatDate(contract.startDate)} - {formatDate(contract.endDate)})
                                    </option>
                                ))}
                            </select>
                        </div>

                        <div className="lg:col-span-4 flex justify-end">
                            <button
                                className="inline-flex items-center gap-2 rounded-lg bg-primary px-5 py-2.5 text-sm font-semibold text-white transition-opacity hover:opacity-90 disabled:cursor-not-allowed disabled:opacity-60"
                                disabled={isUploadingDocument}
                                type="submit"
                            >
                                <span className="material-symbols-outlined text-base">upload</span>
                                {isUploadingDocument ? "Mengunggah..." : "Upload Dokumen"}
                            </button>
                        </div>
                    </form>

                    {uploadFeedback && (
                        <div className="rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm font-medium text-emerald-700">
                            {uploadFeedback}
                        </div>
                    )}

                    {documentsError && (
                        <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm font-medium text-red-700">
                            {documentsError}
                        </div>
                    )}

                    <div className="overflow-hidden rounded-xl border border-slate-100 bg-white shadow-sm">
                        <div className="overflow-x-auto">
                            <table className="w-full min-w-[860px] border-collapse">
                                <thead>
                                    <tr className="border-b border-slate-100 bg-slate-50/80">
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">
                                            Jenis
                                        </th>
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">
                                            Nomor
                                        </th>
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">
                                            Tanggal
                                        </th>
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">
                                            Kontrak
                                        </th>
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">
                                            Arsip
                                        </th>
                                        <th className="px-4 py-3 text-right text-[11px] font-black uppercase tracking-wider text-slate-500">
                                            Aksi
                                        </th>
                                    </tr>
                                </thead>

                                <tbody className="divide-y divide-slate-100">
                                    {isLoadingDocuments && (
                                        <tr>
                                            <td className="px-4 py-6 text-center text-sm text-slate-500" colSpan="6">
                                                Memuat dokumen...
                                            </td>
                                        </tr>
                                    )}

                                    {!isLoadingDocuments && documents.length === 0 && (
                                        <tr>
                                            <td className="px-4 py-6 text-center text-sm text-slate-500" colSpan="6">
                                                Belum ada dokumen untuk filter ini.
                                            </td>
                                        </tr>
                                    )}

                                    {!isLoadingDocuments &&
                                        documents.map((document) => (
                                            <tr key={document.id} className="hover:bg-slate-50/80">
                                                <td className="px-4 py-3">
                                                    <span
                                                        className={`rounded-full px-2.5 py-1 text-[11px] font-bold ${documentTypeBadgeClass[document.jenisDokumen] ?? "bg-slate-100 text-slate-700"}`}
                                                    >
                                                        {documentTypeLabelMap[document.jenisDokumen] || document.jenisDokumen}
                                                    </span>
                                                </td>
                                                <td className="px-4 py-3 text-sm text-slate-700">
                                                    {document.nomorDokumen || "-"}
                                                </td>
                                                <td className="px-4 py-3 text-sm text-slate-700">{formatDate(document.tanggalDokumen)}</td>
                                                <td className="px-4 py-3 text-sm text-slate-700">
                                                    {document.contractId ? `#${document.contractId}` : "-"}
                                                </td>
                                                <td className="px-4 py-3 text-sm">
                                                    {isExternalFileUrl(document.fileUrl) ? (
                                                        <a
                                                            className="font-semibold text-primary hover:underline"
                                                            href={document.fileUrl}
                                                            rel="noreferrer"
                                                            target="_blank"
                                                        >
                                                            Buka File
                                                        </a>
                                                    ) : (
                                                        <span className="font-semibold text-slate-500">Arsip Internal</span>
                                                    )}
                                                </td>
                                                <td className="px-4 py-3 text-right">
                                                    <button
                                                        className="rounded-lg px-3 py-1.5 text-xs font-semibold text-red-600 transition-colors hover:bg-red-50"
                                                        onClick={() => {
                                                            void handleDeleteDocument(document.id);
                                                        }}
                                                        type="button"
                                                    >
                                                        Hapus
                                                    </button>
                                                </td>
                                            </tr>
                                        ))}
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>
            )}

            {contractEditor && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/20 px-4">
                    <div className="w-full max-w-lg rounded-2xl border border-slate-100 bg-white p-6 shadow-2xl">
                        <div className="mb-4 flex items-start justify-between gap-4">
                            <div>
                                <p className="text-xs font-black uppercase tracking-widest text-primary">
                                    {contractEditor.mode === "create" ? "Tambah Kontrak" : "Edit Kontrak"}
                                </p>
                                <h3 className="text-xl font-bold text-on-surface">{customerName}</h3>
                                <p className="text-xs text-on-surface-variant">Isi periode kontrak sesuai data terbaru.</p>
                            </div>

                            <button
                                className="rounded-lg bg-slate-100 p-2 text-slate-500 transition-colors hover:bg-slate-200"
                                onClick={() => {
                                    setContractEditor(null);
                                    setContractEditorError("");
                                }}
                                type="button"
                            >
                                <span className="material-symbols-outlined text-base">close</span>
                            </button>
                        </div>

                        <form className="space-y-4" onSubmit={handleSubmitContractEditor}>
                            <div>
                                <label className="mb-1 block text-xs font-bold uppercase tracking-wider text-slate-500">
                                    Nomor Kontrak
                                </label>
                                <input
                                    className="w-full rounded-lg border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm focus:border-primary focus:ring-2 focus:ring-primary/20"
                                    onChange={(event) =>
                                        setContractEditor((previous) =>
                                            previous
                                                ? {
                                                    ...previous,
                                                    contractNumber: event.target.value,
                                                }
                                                : previous,
                                        )
                                    }
                                    placeholder="CTR-2026-0001"
                                    type="text"
                                    value={contractEditor.contractNumber}
                                />
                            </div>

                            <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                                <div>
                                    <label className="mb-1 block text-xs font-bold uppercase tracking-wider text-slate-500">
                                        Periode Awal
                                    </label>
                                    <input
                                        className="w-full rounded-lg border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm focus:border-primary focus:ring-2 focus:ring-primary/20"
                                        onChange={(event) =>
                                            setContractEditor((previous) =>
                                                previous
                                                    ? {
                                                        ...previous,
                                                        startDate: event.target.value,
                                                    }
                                                    : previous,
                                            )
                                        }
                                        type="date"
                                        value={contractEditor.startDate}
                                    />
                                </div>

                                <div>
                                    <label className="mb-1 block text-xs font-bold uppercase tracking-wider text-slate-500">
                                        Periode Akhir
                                    </label>
                                    <input
                                        className="w-full rounded-lg border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm focus:border-primary focus:ring-2 focus:ring-primary/20"
                                        onChange={(event) =>
                                            setContractEditor((previous) =>
                                                previous
                                                    ? {
                                                        ...previous,
                                                        endDate: event.target.value,
                                                    }
                                                    : previous,
                                            )
                                        }
                                        type="date"
                                        value={contractEditor.endDate}
                                    />
                                </div>
                            </div>

                            {contractEditor.mode === "edit" && (
                                <div>
                                    <label className="mb-1 block text-xs font-bold uppercase tracking-wider text-slate-500">
                                        Status
                                    </label>
                                    <select
                                        className="w-full rounded-lg border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm focus:border-primary focus:ring-2 focus:ring-primary/20"
                                        onChange={(event) =>
                                            setContractEditor((previous) =>
                                                previous
                                                    ? {
                                                        ...previous,
                                                        status: event.target.value,
                                                    }
                                                    : previous,
                                            )
                                        }
                                        value={contractEditor.status}
                                    >
                                        <option value="aktif">Aktif</option>
                                        <option value="expired">Expired</option>
                                        <option value="terminated">Terminated</option>
                                    </select>
                                </div>
                            )}

                            {contractEditorError && (
                                <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm font-medium text-red-700">
                                    {contractEditorError}
                                </div>
                            )}

                            <div className="flex justify-end gap-2">
                                <button
                                    className="rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-600 transition-colors hover:bg-slate-50"
                                    onClick={() => {
                                        setContractEditor(null);
                                        setContractEditorError("");
                                    }}
                                    type="button"
                                >
                                    Batal
                                </button>
                                <button
                                    className="rounded-lg bg-primary px-4 py-2 text-sm font-semibold text-white transition-opacity hover:opacity-90 disabled:cursor-not-allowed disabled:opacity-60"
                                    disabled={isSubmittingContractEditor}
                                    type="submit"
                                >
                                    {isSubmittingContractEditor ? "Menyimpan..." : "Simpan Kontrak"}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            {invoiceUploadDraft && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/20 px-4">
                    <div className="w-full max-w-lg rounded-2xl border border-slate-100 bg-white p-6 shadow-2xl">
                        <div className="mb-4 flex items-start justify-between gap-4">
                            <div>
                                <p className="text-xs font-black uppercase tracking-widest text-primary">Upload Invoice</p>
                                <h3 className="text-xl font-bold text-on-surface">{customerName}</h3>
                                <p className="text-xs text-on-surface-variant">
                                    Invoice #{invoiceUploadDraft.invoiceId}
                                </p>
                            </div>

                            <button
                                className="rounded-lg bg-slate-100 p-2 text-slate-500 transition-colors hover:bg-slate-200"
                                onClick={() => setInvoiceUploadDraft(null)}
                                type="button"
                            >
                                <span className="material-symbols-outlined text-base">close</span>
                            </button>
                        </div>

                        <form className="space-y-4" onSubmit={handleSubmitInvoiceUpload}>
                            <div>
                                <label className="mb-1 block text-xs font-bold uppercase tracking-wider text-slate-500">
                                    Nomor Invoice
                                </label>
                                <input
                                    className="w-full rounded-lg border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm focus:border-primary focus:ring-2 focus:ring-primary/20"
                                    onChange={(event) =>
                                        setInvoiceUploadDraft((previous) =>
                                            previous
                                                ? {
                                                    ...previous,
                                                    invoiceNumber: event.target.value,
                                                }
                                                : previous,
                                        )
                                    }
                                    placeholder="INV-XXXX-XXX"
                                    type="text"
                                    value={invoiceUploadDraft.invoiceNumber}
                                />
                            </div>

                            <div>
                                <label className="mb-1 block text-xs font-bold uppercase tracking-wider text-slate-500">
                                    Tanggal Invoice
                                </label>
                                <input
                                    className="w-full rounded-lg border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm focus:border-primary focus:ring-2 focus:ring-primary/20"
                                    onChange={(event) =>
                                        setInvoiceUploadDraft((previous) =>
                                            previous
                                                ? {
                                                    ...previous,
                                                    tanggalDokumen: event.target.value,
                                                }
                                                : previous,
                                        )
                                    }
                                    type="date"
                                    value={invoiceUploadDraft.tanggalDokumen}
                                />
                            </div>

                            {invoiceUploadError && (
                                <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm font-medium text-red-700">
                                    {invoiceUploadError}
                                </div>
                            )}

                            <div className="flex justify-end gap-2">
                                <button
                                    className="rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-600 transition-colors hover:bg-slate-50"
                                    onClick={() => setInvoiceUploadDraft(null)}
                                    type="button"
                                >
                                    Batal
                                </button>
                                <button
                                    className="rounded-lg bg-primary px-4 py-2 text-sm font-semibold text-white transition-opacity hover:opacity-90 disabled:cursor-not-allowed disabled:opacity-60"
                                    disabled={isUploadingInvoiceDocument}
                                    type="submit"
                                >
                                    {isUploadingInvoiceDocument ? "Mengunggah..." : "Simpan Invoice"}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </AppShell>
    );
}

function CustomerWorkspacePage({
    activeSection,
    customers,
    isps,
    error,
    secondaryError,
    isLoading,
    onNavigate,
    onOpenTenant,
    onOpenIsp,
    onOpenCreateTenant,
    onOpenCreateIsp,
    onRefresh,
}) {
    const [searchTerm, setSearchTerm] = useState("");
    const [collapsedMap, setCollapsedMap] = useState({});
    const normalizedSearch = searchTerm.trim().toLowerCase();

    const groups = useMemo(() => isps
        .map((isp) => {
            const tenants = customers
                .filter((customer) => Array.isArray(customer.ispList) && customer.ispList.includes(isp.name))
                .sort((left, right) => left.name.localeCompare(right.name));

            return {
                ...isp,
                tenants,
                activeTenantCount: tenants.filter((tenant) => tenant.rawStatus === "aktif").length,
            };
        })
        .filter((group) =>
            !normalizedSearch
            || group.name.toLowerCase().includes(normalizedSearch)
            || group.tenants.some((tenant) => tenant.name.toLowerCase().includes(normalizedSearch)))
        .sort((left, right) => left.name.localeCompare(right.name)), [customers, isps, normalizedSearch]);

    const totalActiveTenants = customers.filter((tenant) => tenant.rawStatus === "aktif").length;
    const totalNonActiveTenants = customers.length - totalActiveTenants;

    return (
        <AppShell activeSection={activeSection} onNavigate={onNavigate}>
            <div className="mx-auto max-w-7xl space-y-8">
                <header className="flex flex-col justify-between gap-5 lg:flex-row lg:items-end">
                    <div>
                        <p className="text-xs font-black uppercase tracking-widest text-on-surface-variant/60">
                            Customer Page
                        </p>
                        <h1 className="mt-2 text-4xl font-extrabold tracking-tight text-primary">
                            ISP & Tenant Management
                        </h1>
                        <p className="mt-2 max-w-2xl text-sm leading-relaxed text-on-surface-variant">
                            ISP dipakai sebagai grouping layer, tenant adalah entitas operasional utama.
                        </p>
                    </div>
                    <div className="flex flex-wrap gap-3">
                        <button
                            className="inline-flex items-center gap-2 rounded-xl border border-slate-200 bg-white px-5 py-3 text-sm font-bold text-slate-700 shadow-sm transition-colors hover:bg-slate-50"
                            onClick={onOpenCreateIsp}
                            type="button"
                        >
                            <span className="material-symbols-outlined text-base">add_link</span>
                            + Tambah ISP
                        </button>
                        <button
                            className="inline-flex items-center gap-2 rounded-xl bg-gradient-to-br from-primary to-primary-container px-5 py-3 text-sm font-bold text-white shadow-lg shadow-primary/20 transition-opacity hover:opacity-95"
                            onClick={onOpenCreateTenant}
                            type="button"
                        >
                            <span className="material-symbols-outlined text-base">person_add</span>
                            + Tambah Tenant
                        </button>
                        <button
                            className="inline-flex items-center gap-2 rounded-xl border border-slate-200 bg-white px-5 py-3 text-sm font-bold text-slate-700 shadow-sm transition-colors hover:bg-slate-50"
                            onClick={() => void onRefresh()}
                            type="button"
                        >
                            <span className="material-symbols-outlined text-base">sync</span>
                            Refresh
                        </button>
                    </div>
                </header>

                {(error || secondaryError) && (
                    <div className="space-y-3">
                        {error && <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm font-medium text-red-700">{error}</div>}
                        {secondaryError && <div className="rounded-lg border border-amber-200 bg-amber-50 px-4 py-3 text-sm font-medium text-amber-700">{secondaryError}</div>}
                    </div>
                )}

                <section className="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4">
                    <SummaryCard label="Total ISP" value={isps.length} icon="device_hub" />
                    <SummaryCard label="Total Tenant" value={customers.length} icon="groups" />
                    <SummaryCard label="Active Tenant" value={totalActiveTenants} icon="check_circle" />
                    <SummaryCard label="Non-active Tenant" value={totalNonActiveTenants} icon="cancel" />
                </section>

                <section className="rounded-2xl bg-surface-container-low p-5">
                    <div className="relative">
                        <span className="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-outline">search</span>
                        <input
                            className="w-full rounded-xl border-none bg-surface-container-lowest py-3 pl-12 pr-4 text-sm shadow-sm focus:ring-2 focus:ring-primary/10"
                            onChange={(event) => setSearchTerm(event.target.value)}
                            placeholder="Search ISP / Tenant"
                            type="text"
                            value={searchTerm}
                        />
                    </div>
                </section>

                <section className="space-y-4">
                    {isLoading && <div className="rounded-2xl border border-slate-100 bg-white px-6 py-6 text-center text-sm text-slate-500 shadow-sm">Memuat data ISP dan tenant...</div>}
                    {!isLoading && groups.map((group) => {
                        const isExpanded = normalizedSearch ? true : !collapsedMap[group.id];
                        return (
                            <div key={group.id} className="overflow-hidden rounded-2xl border border-slate-100 bg-surface-container-lowest shadow-sm">
                                <div className="flex flex-col gap-4 bg-slate-50/70 px-6 py-5 lg:flex-row lg:items-center lg:justify-between">
                                    <button
                                        className="flex flex-1 items-center justify-between gap-4 text-left"
                                        onClick={() => setCollapsedMap((previous) => ({ ...previous, [group.id]: !previous[group.id] }))}
                                        type="button"
                                    >
                                        <div>
                                            <p className="text-[10px] font-black uppercase tracking-widest text-slate-500">ISP</p>
                                            <h3 className="mt-1 text-lg font-extrabold text-primary">{group.name}</h3>
                                            <p className="mt-1 text-xs text-slate-500">Kontrak induk: {group.contractReference || "-"}</p>
                                        </div>
                                        <span className={`material-symbols-outlined text-slate-500 transition-transform ${isExpanded ? "rotate-180" : ""}`}>expand_more</span>
                                    </button>
                                    <div className="flex flex-wrap items-center gap-2">
                                        <span className="rounded-full bg-blue-100 px-3 py-1 text-[11px] font-bold text-blue-700">{group.tenants.length} tenant</span>
                                        <button
                                            className="rounded-lg border border-slate-200 bg-white px-3 py-2 text-xs font-semibold text-slate-700 transition-colors hover:bg-slate-50"
                                            onClick={() => onOpenIsp(group)}
                                            type="button"
                                        >
                                            Detail ISP
                                        </button>
                                    </div>
                                </div>

                                {isExpanded && (
                                    <div className="border-t border-slate-100">
                                        <div className="overflow-x-auto">
                                            <table className="w-full border-collapse">
                                                <thead>
                                                    <tr className="bg-white">
                                                        <th className="px-6 py-3 text-left text-[10px] font-black uppercase tracking-widest text-slate-500">Tenant</th>
                                                        <th className="px-6 py-3 text-left text-[10px] font-black uppercase tracking-widest text-slate-500">Status</th>
                                                        <th className="px-6 py-3 text-left text-[10px] font-black uppercase tracking-widest text-slate-500">To Do</th>
                                                        <th className="px-6 py-3 text-right text-[10px] font-black uppercase tracking-widest text-slate-500">Aksi</th>
                                                    </tr>
                                                </thead>
                                                <tbody className="divide-y divide-slate-100">
                                                    {group.tenants.map((tenant) => (
                                                        <tr key={`${group.id}-${tenant.id}`} className="hover:bg-slate-50/80">
                                                            <td className="px-6 py-4">
                                                                <p className="text-sm font-semibold text-on-surface">{tenant.name}</p>
                                                                <p className="mt-1 text-[11px] text-slate-500">{tenant.customerId}</p>
                                                            </td>
                                                            <td className="px-6 py-4 text-sm text-slate-600">{tenant.rawStatus === "aktif" ? "Aktif" : "Non-aktif"}</td>
                                                            <td className="px-6 py-4 text-sm text-slate-600">
                                                                {tenant.todoSummary?.counts?.priority ?? 0} prioritas / {tenant.todoSummary?.counts?.needAction ?? 0} tindakan
                                                            </td>
                                                            <td className="px-6 py-4 text-right">
                                                                <button
                                                                    className="inline-flex items-center gap-1 rounded-lg bg-primary/5 px-3 py-2 text-primary transition-colors hover:bg-primary/10"
                                                                    onClick={() => onOpenTenant(tenant, "overview", group)}
                                                                    type="button"
                                                                >
                                                                    <span className="material-symbols-outlined text-base">visibility</span>
                                                                    Detail Tenant
                                                                </button>
                                                            </td>
                                                        </tr>
                                                    ))}
                                                    {group.tenants.length === 0 && (
                                                        <tr>
                                                            <td className="px-6 py-6 text-center text-sm text-slate-500" colSpan="4">
                                                                Belum ada tenant yang terhubung ke ISP ini.
                                                            </td>
                                                        </tr>
                                                    )}
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                )}
                            </div>
                        );
                    })}
                    {!isLoading && groups.length === 0 && <div className="rounded-2xl border border-slate-100 bg-white px-6 py-10 text-center shadow-sm"><p className="text-base font-bold text-on-surface">Tidak ada data yang cocok.</p></div>}
                </section>
            </div>
        </AppShell>
    );
}

function TenantAdminFormPage({ isps = [], onCancel, onNavigate, onSaved }) {
    const [form, setForm] = useState({
        name: "",
        status: "aktif",
        ratioLeft: "1",
        ratioRight: "8",
        contractStartDate: "",
        contractEndDate: "",
        billingPeriodMode: "bulanan",
        billingCustomEvery: "",
        billingCustomUnit: "bulan",
        activationFeeAmount: "0",
        contractNumber: "",
        newIspName: "",
    });
    const [selectedIspIds, setSelectedIspIds] = useState([]);
    const [submitError, setSubmitError] = useState("");
    const [isSubmitting, setIsSubmitting] = useState(false);

    const toggleIsp = (ispId) => {
        setSelectedIspIds((previous) =>
            previous.includes(ispId)
                ? previous.filter((value) => value !== ispId)
                : [...previous, ispId]);
    };

    const handleSubmit = async (event) => {
        event.preventDefault();

        if (!form.name.trim()) {
            setSubmitError("Nama tenant wajib diisi.");
            return;
        }
        if (selectedIspIds.length === 0 && !form.newIspName.trim()) {
            setSubmitError("Tenant harus terhubung ke minimal satu ISP atau masukkan nama ISP baru.");
            return;
        }
        if (!form.ratioLeft || !form.ratioRight || Number(form.ratioLeft) < 1 || Number(form.ratioRight) < 1) {
            setSubmitError("Shared Core ratio tidak valid. Masukkan angka >= 1 di kedua kolom.");
            return;
        }
        if (!form.contractStartDate || !form.contractEndDate || form.contractStartDate > form.contractEndDate) {
            setSubmitError("Periode kontrak tenant tidak valid.");
            return;
        }

        setIsSubmitting(true);
        setSubmitError("");

        try {
            const result = await fetchJson(`${API_BASE_URL}/api/customers`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    name: form.name.trim(),
                    status: form.status,
                    ispIds: selectedIspIds,
                    newIspNames: form.newIspName.trim() ? [form.newIspName.trim()] : undefined,
                    contractNumber: form.contractNumber.trim() || undefined,
                    contractStartDate: form.contractStartDate,
                    contractEndDate: form.contractEndDate,
                    contractSharingRatio: `${form.ratioLeft || 1}:${form.ratioRight || 8}`,
                    billingPeriodMode: form.billingPeriodMode,
                    billingCustomEvery: form.billingPeriodMode === "custom" ? Number(form.billingCustomEvery) : undefined,
                    billingCustomUnit: form.billingPeriodMode === "custom" ? form.billingCustomUnit : undefined,
                    activationFeeAmount: Math.round(Number(form.activationFeeAmount || 0)),
                }),
            });

            if (onSaved) {
                await onSaved(result);
            }
        } catch (requestError) {
            setSubmitError(requestError instanceof Error ? requestError.message : "Terjadi kesalahan saat menyimpan tenant.");
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <AppShell activeSection="customers" onNavigate={onNavigate}>
            <form className="mx-auto max-w-6xl space-y-8" onSubmit={handleSubmit}>
                <div className="flex flex-col justify-between gap-4 md:flex-row md:items-end">
                    <div>
                        <p className="text-xs font-black uppercase tracking-widest text-on-surface-variant/60">Tambah Tenant</p>
                        <h1 className="mt-2 text-3xl font-extrabold text-primary">Tenant Baru</h1>
                        <p className="mt-2 max-w-xl text-sm text-on-surface-variant">
                            Sistem akan otomatis membuat kontrak, contract version awal, dan draft invoice.
                        </p>
                    </div>
                    <div className="flex gap-3">
                        <button className="rounded-xl px-6 py-2.5 font-semibold text-on-surface-variant transition-all hover:bg-surface-container-high" onClick={onCancel} type="button">Batalkan</button>
                        <button className="rounded-xl bg-gradient-to-br from-primary to-primary-container px-8 py-2.5 font-bold text-white shadow-lg shadow-primary/20 transition-opacity hover:opacity-95 disabled:cursor-not-allowed disabled:opacity-60" disabled={isSubmitting} type="submit">{isSubmitting ? "Menyimpan..." : "Simpan Tenant"}</button>
                    </div>
                </div>

                {submitError && <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm font-medium text-red-700">{submitError}</div>}

                <div className="grid grid-cols-12 gap-8">
                    <section className="col-span-12 space-y-8 lg:col-span-8">
                        <div className="rounded-lg bg-surface-container-lowest p-8 shadow-sm">
                            <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
                                <FieldInput label="Nama Tenant" value={form.name} onChange={(value) => setForm((previous) => ({ ...previous, name: value }))} />
                                <FieldSelect label="Status" value={form.status} onChange={(value) => setForm((previous) => ({ ...previous, status: value }))} options={[{ value: "aktif", label: "Aktif" }, { value: "nonaktif", label: "Non-aktif" }]} />
                                <div>
                                <label className="mb-2 block text-[10px] font-bold uppercase tracking-widest text-on-surface-variant">Rasio Shared Core</label>
                                <div className="flex items-center gap-2">
                                    <input className="w-24 rounded-lg border border-slate-200 bg-surface-container-lowest px-3 py-2.5 text-sm focus:border-primary focus:ring-2 focus:ring-primary/10" type="number" min="1" value={form.ratioLeft} onChange={(e) => setForm((prev) => ({ ...prev, ratioLeft: e.target.value }))} placeholder="1" />
                                    <span className="text-lg font-bold text-slate-400">:</span>
                                    <input className="w-24 rounded-lg border border-slate-200 bg-surface-container-lowest px-3 py-2.5 text-sm focus:border-primary focus:ring-2 focus:ring-primary/10" type="number" min="1" value={form.ratioRight} onChange={(e) => setForm((prev) => ({ ...prev, ratioRight: e.target.value }))} placeholder="8" />
                                </div>
                            </div>
                                <FieldInput label="Nomor Kontrak" value={form.contractNumber} onChange={(value) => setForm((previous) => ({ ...previous, contractNumber: value }))} placeholder="Otomatis jika kosong" />
                                <FieldInput label="Contract Start" type="date" value={form.contractStartDate} onChange={(value) => setForm((previous) => ({ ...previous, contractStartDate: value }))} />
                                <FieldInput label="Contract End" type="date" value={form.contractEndDate} onChange={(value) => setForm((previous) => ({ ...previous, contractEndDate: value }))} />
                            </div>
                        </div>

                        <div className="rounded-lg bg-surface-container-lowest p-8 shadow-sm">
                            <div className="mb-6 flex items-center justify-between gap-3">
                                <h3 className="text-lg font-bold text-blue-950">Pilih ISP</h3>
                                <p className="text-xs text-slate-500">Gunakan tombol `Tambah ISP` jika ISP belum tersedia.</p>
                            </div>
                            <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
                                {isps.map((isp) => (
                                    <label key={isp.id} className={`flex cursor-pointer items-start gap-3 rounded-xl border p-4 transition-colors ${selectedIspIds.includes(isp.id) ? "border-primary bg-blue-50/60" : "border-slate-200 bg-white"}`}>
                                        <input checked={selectedIspIds.includes(isp.id)} className="mt-1" onChange={() => toggleIsp(isp.id)} type="checkbox" />
                                        <div>
                                            <p className="text-sm font-semibold text-slate-800">{isp.name}</p>
                                            <p className="mt-1 text-xs text-slate-500">{isp.contractReference || "Tanpa referensi kontrak"}</p>
                                        </div>
                                    </label>
                                ))}
                            </div>
                            <div className="mt-4 pt-4 border-t border-slate-100">
                                <h4 className="mb-3 text-sm font-bold text-slate-800">Atau Tambah ISP Baru</h4>
                                <FieldInput label="Nama ISP Baru (Opsional)" value={form.newIspName} onChange={(value) => setForm((previous) => ({ ...previous, newIspName: value }))} placeholder="Ketik nama ISP jika belum ada di atas" />
                            </div>
                        </div>
                    </section>

                    <section className="col-span-12 space-y-8 lg:col-span-4">
                        <div className="rounded-lg bg-surface-container-low p-6">
                            <div className="space-y-6">
                                <div>
                                    <label className="mb-3 block text-[10px] font-bold uppercase tracking-widest text-on-surface-variant">Billing Period</label>
                                    <div className="grid grid-cols-3 gap-2">
                                        {["bulanan", "3bulanan", "custom"].map((mode) => (
                                            <button key={mode} className={`rounded-lg py-2 text-xs font-bold transition-colors ${form.billingPeriodMode === mode ? "bg-primary text-white" : "bg-surface-container-lowest text-on-surface-variant hover:bg-slate-200"}`} onClick={() => setForm((previous) => ({ ...previous, billingPeriodMode: mode }))} type="button">{mode === "bulanan" ? "Bulanan" : mode === "3bulanan" ? "3 Bulanan" : "Custom"}</button>
                                        ))}
                                    </div>
                                    <div className="mt-3 rounded-xl bg-surface-container-lowest p-4">
                                        <div className="flex gap-2">
                                            <input className="w-20 rounded-lg border-none bg-surface p-2 text-xs disabled:bg-slate-200" disabled={form.billingPeriodMode !== "custom"} min="1" onChange={(event) => setForm((previous) => ({ ...previous, billingCustomEvery: event.target.value }))} step="1" type="number" value={form.billingCustomEvery} />
                                            <select className="flex-1 rounded-lg border-none bg-surface p-2 text-xs disabled:bg-slate-200" disabled={form.billingPeriodMode !== "custom"} onChange={(event) => setForm((previous) => ({ ...previous, billingCustomUnit: event.target.value }))} value={form.billingCustomUnit}>
                                                <option value="hari">Hari</option>
                                                <option value="bulan">Bulan</option>
                                                <option value="tahun">Tahun</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                                <FieldInput label="Biaya Aktivasi" type="number" value={form.activationFeeAmount} onChange={(value) => setForm((previous) => ({ ...previous, activationFeeAmount: value }))} />
                            </div>
                        </div>
                    </section>
                </div>
            </form>
        </AppShell>
    );
}

function IspAdminFormPage({ onCancel, onNavigate, onSaved }) {
    const [form, setForm] = useState({
        name: "",
        status: "aktif",
        contractReference: "",
        contractStartDate: "",
        contractPeriodStart: "",
        contractPeriodEnd: "",
        paket: "core",
        jumlah: "0",
        ratioLeft: "1",
        ratioRight: "8",
    });
    const [submitError, setSubmitError] = useState("");
    const [isSubmitting, setIsSubmitting] = useState(false);

    const handleSubmit = async (event) => {
        event.preventDefault();
        if (!form.name.trim() || !form.contractReference.trim()) {
            setSubmitError("Nama ISP dan nomor kontrak induk wajib diisi.");
            return;
        }

        setIsSubmitting(true);
        setSubmitError("");
        try {
            const result = await fetchJson(`${API_BASE_URL}/api/isps`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    name: form.name.trim(),
                    status: form.status,
                    contractReference: form.contractReference.trim(),
                    contractStartDate: form.contractStartDate || null,
                    contractPeriodStart: form.contractPeriodStart || null,
                    contractPeriodEnd: form.contractPeriodEnd || null,
                    paket: form.paket,
                    jumlah: form.paket === "core" ? Math.round(Number(form.jumlah || 0)) : 0,
                    sharingRatio: form.paket === "shared" ? `${form.ratioLeft || 1}:${form.ratioRight || 8}` : undefined,
                }),
            });
            if (onSaved) {
                await onSaved(result);
            }
        } catch (requestError) {
            setSubmitError(requestError instanceof Error ? requestError.message : "Terjadi kesalahan saat menyimpan ISP.");
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <AppShell activeSection="customers" onNavigate={onNavigate}>
            <form className="mx-auto max-w-5xl space-y-8" onSubmit={handleSubmit}>
                <div className="flex flex-col justify-between gap-4 md:flex-row md:items-end">
                    <div>
                        <p className="text-xs font-black uppercase tracking-widest text-on-surface-variant/60">Tambah ISP</p>
                        <h1 className="mt-2 text-3xl font-extrabold text-primary">ISP Baru</h1>
                    </div>
                    <div className="flex gap-3">
                        <button className="rounded-xl px-6 py-2.5 font-semibold text-on-surface-variant transition-all hover:bg-surface-container-high" onClick={onCancel} type="button">Batalkan</button>
                        <button className="rounded-xl bg-gradient-to-br from-primary to-primary-container px-8 py-2.5 font-bold text-white shadow-lg shadow-primary/20 transition-opacity hover:opacity-95 disabled:cursor-not-allowed disabled:opacity-60" disabled={isSubmitting} type="submit">{isSubmitting ? "Menyimpan..." : "Simpan ISP"}</button>
                    </div>
                </div>

                {submitError && <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm font-medium text-red-700">{submitError}</div>}

                <div className="rounded-lg bg-surface-container-lowest p-8 shadow-sm">
                    <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
                        <FieldInput label="Nama ISP" value={form.name} onChange={(value) => setForm((previous) => ({ ...previous, name: value }))} />
                        <FieldSelect label="Status" value={form.status} onChange={(value) => setForm((previous) => ({ ...previous, status: value }))} options={[{ value: "aktif", label: "Aktif" }, { value: "nonaktif", label: "Non-aktif" }]} />
                        <FieldInput label="Nomor kontrak induk" value={form.contractReference} onChange={(value) => setForm((previous) => ({ ...previous, contractReference: value }))} />
                        <FieldInput label="Awal kontrak" type="date" value={form.contractStartDate} onChange={(value) => setForm((previous) => ({ ...previous, contractStartDate: value }))} />
                        <FieldInput label="Periode berjalan mulai" type="date" value={form.contractPeriodStart} onChange={(value) => setForm((previous) => ({ ...previous, contractPeriodStart: value }))} />
                        <FieldInput label="Periode berjalan akhir" type="date" value={form.contractPeriodEnd} onChange={(value) => setForm((previous) => ({ ...previous, contractPeriodEnd: value }))} />
                        <FieldSelect label="Paket" value={form.paket} onChange={(value) => setForm((previous) => ({ ...previous, paket: value }))} options={[{ value: "core", label: "Core" }, { value: "shared", label: "Shared Core" }]} />
                        {form.paket === "core" ? (
                            <FieldInput label="Jumlah Core" type="number" value={form.jumlah} onChange={(value) => setForm((previous) => ({ ...previous, jumlah: value }))} placeholder="Contoh: 4" />
                        ) : (
                            <div>
                                <label className="mb-2 block text-[10px] font-bold uppercase tracking-widest text-on-surface-variant">Rasio Shared Core</label>
                                <div className="flex items-center gap-2">
                                    <input className="w-24 rounded-lg border border-slate-200 bg-surface-container-lowest px-3 py-2.5 text-sm focus:border-primary focus:ring-2 focus:ring-primary/10" type="number" min="1" value={form.ratioLeft} onChange={(e) => setForm((prev) => ({ ...prev, ratioLeft: e.target.value }))} placeholder="1" />
                                    <span className="text-lg font-bold text-slate-400">:</span>
                                    <input className="w-24 rounded-lg border border-slate-200 bg-surface-container-lowest px-3 py-2.5 text-sm focus:border-primary focus:ring-2 focus:ring-primary/10" type="number" min="1" value={form.ratioRight} onChange={(e) => setForm((prev) => ({ ...prev, ratioRight: e.target.value }))} placeholder="8" />
                                </div>
                            </div>
                        )}
                    </div>
                </div>
            </form>
        </AppShell>
    );
}


function IspDetailPage({ isp, onBack, onNavigate, onOpenTenant, onRefreshAll }) {
    const [detail, setDetail] = useState(null);
    const [activeTab, setActiveTab] = useState("overview");
    const [error, setError] = useState("");
    const [isLoading, setIsLoading] = useState(false);
    const [timeline, setTimeline] = useState([]);

    const loadDetail = useCallback(async () => {
        setIsLoading(true);
        setError("");
        try {
            // Note: In real app we fetch ISP details, contracts, invoices, timeline
            const result = await fetchJson(`${API_BASE_URL}/api/isps/${isp.id}`);
            setDetail(result ?? null);
            setTimeline([
                { id: `t1-${isp.id}`, date: new Date().toISOString(), type: "todo", title: "Pembuatan ISP", description: "ISP dibuat di sistem." }
            ]);
        } catch (requestError) {
            setError(requestError instanceof Error ? requestError.message : "Terjadi kesalahan saat memuat detail ISP.");
        } finally {
            setIsLoading(false);
        }
    }, [isp.id]);

    useEffect(() => {
        void loadDetail();
    }, [loadDetail]);

    const tenants = Array.isArray(detail?.tenants) ? detail.tenants : [];
    const contracts = Array.isArray(detail?.contracts) ? detail.contracts : [];
    const invoices = Array.isArray(detail?.invoices) ? detail.invoices : [];
    const summary = detail?.summary ?? {};
    
    // Derived header properties
    const ispName = detail?.name ?? isp.name;
    const contractRef = detail?.contractReference ?? isp.contractReference ?? "-";
    const paketStr = (detail?.paket || isp.paket) === "shared" ? "Shared Core" : "Core";
    const jumlahStr = detail?.jumlah || isp.jumlah || "-";

    const renderEmptyState = (message) => (
        <div className="rounded-2xl border border-slate-100 bg-white p-12 text-center shadow-sm">
            <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-slate-50">
                <span className="material-symbols-outlined text-3xl text-slate-300">inbox</span>
            </div>
            <h3 className="mt-4 text-base font-bold text-slate-700">Belum Ada Data</h3>
            <p className="mt-1 text-sm text-slate-500">{message}</p>
        </div>
    );

    return (
        <AppShell activeSection="customers" onNavigate={onNavigate}>
            <div className="mx-auto max-w-7xl space-y-8">
                <button className="inline-flex items-center gap-2 rounded-lg bg-surface-container-low px-4 py-2 text-sm font-semibold text-primary transition-colors hover:bg-surface-container" onClick={onBack} type="button">
                    <span className="material-symbols-outlined text-base">arrow_back</span>
                    Kembali ke Customer Page
                </button>

                <section className="rounded-2xl bg-gradient-to-br from-primary/10 to-primary-container p-6 lg:p-8">
                    <div className="flex flex-col justify-between gap-6 lg:flex-row lg:items-start">
                        <div className="space-y-4">
                            <div>
                                <div className="mb-2 inline-flex items-center gap-2">
                                    <span className="rounded-md bg-white/50 px-2.5 py-1 text-[10px] font-black uppercase tracking-widest text-primary">
                                        ISP
                                    </span>
                                    <span className="rounded-md bg-white/50 px-2.5 py-1 text-[10px] font-black uppercase tracking-widest text-primary">
                                        {((detail?.status ?? isp.status) === "aktif") ? "Aktif" : "Non-aktif"}
                                    </span>
                                </div>
                                <h1 className="text-4xl font-extrabold tracking-tight text-blue-950">{ispName}</h1>
                                <p className="mt-2 flex items-center gap-2 text-sm text-slate-600">
                                    <span className="material-symbols-outlined text-base">description</span>
                                    Kontrak Induk: {contractRef}
                                </p>
                            </div>
                            <div className="flex flex-wrap gap-4">
                                <div className="rounded-xl bg-white/60 px-4 py-3 shadow-sm">
                                    <p className="text-[10px] font-bold uppercase tracking-widest text-slate-500">Paket Default</p>
                                    <p className="mt-1 text-sm font-bold text-slate-800">{paketStr} ({jumlahStr})</p>
                                </div>
                                <div className="rounded-xl bg-white/60 px-4 py-3 shadow-sm">
                                    <p className="text-[10px] font-bold uppercase tracking-widest text-slate-500">Periode Berjalan</p>
                                    <p className="mt-1 text-sm font-bold text-slate-800">{formatContractPeriod(detail?.contractPeriodStart ?? isp.contractPeriodStart, detail?.contractPeriodEnd ?? isp.contractPeriodEnd)}</p>
                                </div>
                            </div>
                        </div>
                        <div className="flex gap-3">
                            <button className="rounded-xl border border-blue-200 bg-white px-5 py-2.5 text-sm font-bold text-blue-700 shadow-sm transition-colors hover:bg-blue-50" onClick={() => void loadDetail()} type="button">
                                Refresh Data
                            </button>
                        </div>
                    </div>
                </section>

                <div className="border-b border-slate-200">
                    <nav className="-mb-px flex gap-6 overflow-x-auto">
                        {[
                            { id: "overview", label: "Ringkasan", icon: "dashboard" },
                            { id: "customers", label: "Customer (Baru)", icon: "groups" },
                            { id: "contracts", label: "Kontrak", icon: "description" },
                            { id: "invoices", label: "Invoice", icon: "receipt_long" },
                            { id: "timeline", label: "Timeline & Log", icon: "history" },
                        ].map((tab) => (
                            <button
                                key={tab.id}
                                className={`flex items-center gap-2 whitespace-nowrap border-b-2 px-1 py-4 text-sm font-semibold transition-colors ${activeTab === tab.id ? "border-primary text-primary" : "border-transparent text-slate-500 hover:border-slate-300 hover:text-slate-700"}`}
                                onClick={() => setActiveTab(tab.id)}
                                type="button">
                                <span className="material-symbols-outlined text-xl">{tab.icon}</span>
                                {tab.label}
                            </button>
                        ))}
                    </nav>
                </div>

                {isLoading && <div className="p-8 text-center text-slate-500">Memuat...</div>}
                
                {!isLoading && activeTab === "overview" && (
                    <div className="space-y-6">
                        <section className="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4">
                            <SummaryCard label="Total Tenant" value={summary.tenantCount ?? tenants.length} icon="groups" />
                            <SummaryCard label="Missing BAK" value={summary.tenantsMissingBak ?? 0} icon="history_toggle_off" />
                            <SummaryCard label="Unpaid Tenant" value={summary.tenantsUnpaid ?? 0} icon="payments" />
                            <SummaryCard label="Expiring Contract" value={summary.tenantsExpiringContract ?? 0} icon="event_busy" />
                        </section>
                        <section className="rounded-2xl bg-surface-container-lowest p-6 shadow-sm">
                            <h3 className="mb-4 text-lg font-bold text-blue-950">Ringkasan Tagihan (Demo)</h3>
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <p className="text-xs font-bold text-slate-500">Total Bulanan (Estimasi)</p>
                                    <p className="mt-1 text-xl font-black text-slate-800">Rp 0</p>
                                </div>
                                <div>
                                    <p className="text-xs font-bold text-slate-500">Biaya Aktivasi Status</p>
                                    <p className="mt-1 text-base font-bold text-slate-800">{(detail?.activationFeeAmount || isp.activationFeeAmount) ? `Rp ${(detail?.activationFeeAmount || isp.activationFeeAmount).toLocaleString('id-ID')} (Menunggu)` : "Selesai"}</p>
                                </div>
                            </div>
                        </section>
                    </div>
                )}

                {!isLoading && activeTab === "customers" && (
                    <section className="rounded-2xl bg-surface-container-lowest p-6 shadow-sm">
                        <div className="mb-4 flex items-center justify-between gap-3">
                            <h2 className="text-lg font-bold text-blue-950">Tenant di Bawah ISP Ini</h2>
                            <button className="rounded-lg bg-primary px-4 py-2 text-xs font-bold text-white">Tambah Tenant</button>
                        </div>
                        {tenants.length === 0 ? renderEmptyState("Belum ada tenant pada ISP ini.") : (
                            <div className="overflow-x-auto">
                                <table className="w-full border-collapse">
                                    <thead>
                                        <tr className="border-b border-slate-100">
                                            <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Tenant</th>
                                            <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Status</th>
                                            <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Shared Core</th>
                                            <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">To Do</th>
                                            <th className="px-4 py-3 text-right text-[11px] font-black uppercase tracking-wider text-slate-500">Aksi</th>
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-slate-100">
                                        {tenants.map((tenant) => (
                                            <tr key={tenant.id} className="hover:bg-slate-50/80">
                                                <td className="px-4 py-3 text-sm font-semibold text-slate-800">{tenant.name}</td>
                                                <td className="px-4 py-3 text-sm text-slate-600">{tenant.status === "aktif" ? "Aktif" : "Non-aktif"}</td>
                                                <td className="px-4 py-3 text-sm text-slate-600">{tenant.contractSharingRatio ?? "-"}</td>
                                                <td className="px-4 py-3 text-sm text-slate-600">{tenant.todoSummary?.counts?.priority ?? 0} prioritas</td>
                                                <td className="px-4 py-3 text-right flex justify-end gap-2">
                                                    <button className="rounded-lg bg-primary/5 px-3 py-2 text-xs font-semibold text-primary transition-colors hover:bg-primary/10" onClick={() => onOpenTenant(tenant, "overview")} type="button">Detail</button>
                                                    <button className="rounded-lg bg-amber-50 px-3 py-2 text-xs font-semibold text-amber-700 transition-colors hover:bg-amber-100" type="button">Edit</button>
                                                    <button className="rounded-lg bg-red-50 px-3 py-2 text-xs font-semibold text-red-700 transition-colors hover:bg-red-100" type="button">Hapus</button>
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        )}
                    </section>
                )}

                {!isLoading && activeTab === "contracts" && (
                    <section className="rounded-2xl bg-surface-container-lowest p-6 shadow-sm">
                        <div className="mb-6 flex flex-wrap items-center justify-between gap-4 border-b border-slate-100 pb-4">
                            <h2 className="text-lg font-bold text-blue-950">Daftar Kontrak (Adendum)</h2>
                            <button className="inline-flex items-center gap-2 rounded-xl bg-primary px-4 py-2 text-sm font-bold text-white shadow-sm transition-colors hover:bg-primary/90" type="button">
                                <span className="material-symbols-outlined text-base">add</span>
                                Tambah Kontrak
                            </button>
                        </div>
                        {contracts.length === 0 ? renderEmptyState("Belum ada kontrak tercatat.") : (
                            <table className="w-full border-collapse">
                                <thead>
                                    <tr className="border-b border-slate-100 bg-slate-50/50">
                                        <th className="px-4 py-3 text-left text-xs font-bold text-slate-500">Nomor</th>
                                        <th className="px-4 py-3 text-left text-xs font-bold text-slate-500">Status</th>
                                        <th className="px-4 py-3 text-left text-xs font-bold text-slate-500">Periode</th>
                                        <th className="px-4 py-3 text-left text-xs font-bold text-slate-500">Dibuat</th>
                                        <th className="px-4 py-3 text-right text-xs font-bold text-slate-500">Aksi</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {contracts.map((c) => (
                                        <tr key={c.id}>
                                            <td className="px-4 py-3 text-sm">{c.contractNumber || "-"}</td>
                                            <td className="px-4 py-3 text-sm">{c.status || "-"}</td>
                                            <td className="px-4 py-3 text-sm">{formatContractPeriod(c.startDate, c.endDate)}</td>
                                            <td className="px-4 py-3 text-sm">{c.createdAt ? new Date(c.createdAt).toLocaleDateString("id-ID") : "-"}</td>
                                            <td className="px-4 py-3 text-right text-sm">
                                                <button className="text-blue-600 hover:underline">Detail</button>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        )}
                    </section>
                )}

                {!isLoading && activeTab === "invoices" && (
                    <section className="rounded-2xl bg-surface-container-lowest p-6 shadow-sm">
                        <div className="mb-6 flex flex-wrap items-center justify-between gap-4 border-b border-slate-100 pb-4">
                            <h2 className="text-lg font-bold text-blue-950">Tagihan & Invoice</h2>
                        </div>
                        {invoices.length === 0 ? renderEmptyState("Belum ada invoice terkait ISP ini.") : (
                            <div className="text-sm text-slate-500">Daftar invoice...</div>
                        )}
                    </section>
                )}

                {!isLoading && activeTab === "timeline" && (
                    <section className="rounded-2xl bg-surface-container-lowest p-6 shadow-sm">
                        <div className="mb-6 border-b border-slate-100 pb-4">
                            <h2 className="text-lg font-bold text-blue-950">Riwayat Aktifitas & Timeline</h2>
                        </div>
                        {timeline.length === 0 ? renderEmptyState("Belum ada aktifitas baru.") : (
                            <div className="space-y-4">
                                {timeline.map((event) => (
                                    <div key={event.id} className="flex gap-4">
                                        <span className="material-symbols-outlined text-slate-400">radio_button_checked</span>
                                        <div>
                                            <p className="text-sm font-bold text-slate-800">{event.title}</p>
                                            <p className="text-xs text-slate-500">{event.description}</p>
                                            <p className="mt-1 text-[10px] text-slate-400">{new Date(event.date).toLocaleString("id-ID")}</p>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}
                    </section>
                )}
            </div>
        </AppShell>
    );
}

function TenantDetailPage({ customer, contextIsp, initialTab = "overview", onBack, onCreateIsp, onNavigate, onRefreshAll }) {
    const [activeTab, setActiveTab] = useState(initialTab);
    const [detail, setDetail] = useState(null);
    const [timeline, setTimeline] = useState([]);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState("");
    const [documentDraft, setDocumentDraft] = useState({
        jenisDokumen: "BAK",
        nomorDokumen: "",
        tanggalDokumen: new Date().toISOString().slice(0, 10),
        contractVersionId: "",
    });
    const [documentError, setDocumentError] = useState("");
    const [documentFeedback, setDocumentFeedback] = useState("");
    const [isUploadingDocument, setIsUploadingDocument] = useState(false);
    const [versionEditor, setVersionEditor] = useState(null);
    const [versionError, setVersionError] = useState("");
    const [isSubmittingVersion, setIsSubmittingVersion] = useState(false);
    const [deleteModalOpen, setDeleteModalOpen] = useState(false);
    const [deleteMode, setDeleteMode] = useState(contextIsp?.id ? "this" : "selected");
    const [selectedDeleteIspIds, setSelectedDeleteIspIds] = useState([]);
    const [deleteError, setDeleteError] = useState("");
    const [isDeletingLink, setIsDeletingLink] = useState(false);

    const loadDetail = useCallback(async () => {
        setIsLoading(true);
        setError("");
        try {
            const [detailResult, timelineResult] = await Promise.all([
                fetchJson(`${API_BASE_URL}/api/customers/${customer.id}`),
                fetchJson(`${API_BASE_URL}/api/customers/${customer.id}/timeline`),
            ]);
            setDetail(detailResult ?? null);
            setTimeline(Array.isArray(timelineResult) ? timelineResult : []);
        } catch (requestError) {
            setError(requestError instanceof Error ? requestError.message : "Terjadi kesalahan saat memuat tenant.");
        } finally {
            setIsLoading(false);
        }
    }, [customer.id]);

    useEffect(() => {
        setActiveTab(initialTab);
        void loadDetail();
    }, [initialTab, loadDetail]);

    const tenantName = detail?.name ?? customer.name;
    const isps = Array.isArray(detail?.isps) ? detail.isps : [];
    const contract = Array.isArray(detail?.contracts) ? detail.contracts[0] ?? null : null;
    const versions = Array.isArray(detail?.contractVersions) ? detail.contractVersions : [];
    const invoices = Array.isArray(detail?.invoices) ? detail.invoices : [];
    const todoSummary = detail?.todoSummary ?? { priority: [], needAction: [], info: [], counts: {} };
    const latestDocuments = Array.isArray(detail?.latestDocuments) ? detail.latestDocuments : [];
    const requiredDocuments = latestDocuments.filter((item) => ["penawaran", "tanggapan", "hasil_nego"].includes(item.jenisDokumen));

    const openVersionEditor = () => {
        const latestVersion = versions[0];
        const nextStartDate = latestVersion?.endDate ? addDaysToIsoDate(latestVersion.endDate, 1) : contract?.startDate ?? "";
        setVersionEditor({
            startDate: nextStartDate,
            endDate: contract?.endDate ?? nextStartDate,
            ratio: latestVersion?.sharedCoreRatio ?? contract?.sharingRatio ?? "1:8",
        });
        setVersionError("");
    };

    const handleCreateVersion = async (event) => {
        event.preventDefault();
        if (!contract || !versionEditor) {
            return;
        }
        if (!/^[1-9]\d*:[1-9]\d*$/.test(versionEditor.ratio.trim())) {
            setVersionError("Rasio shared core tidak valid.");
            return;
        }
        setIsSubmittingVersion(true);
        setVersionError("");
        try {
            await fetchJson(`${API_BASE_URL}/api/customers/${customer.id}/contracts/${contract.id}/versions`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    startDate: versionEditor.startDate,
                    endDate: versionEditor.endDate,
                    sharedCoreRatio: versionEditor.ratio.trim(),
                }),
            });
            setVersionEditor(null);
            setDocumentFeedback("Riwayat perubahan kontrak berhasil dibuat. Upload BAK untuk mengaktifkan versi baru.");
            await Promise.all([loadDetail(), onRefreshAll?.()]);
        } catch (requestError) {
            setVersionError(requestError instanceof Error ? requestError.message : "Terjadi kesalahan saat membuat versi kontrak.");
        } finally {
            setIsSubmittingVersion(false);
        }
    };

    const handleUploadDocument = async (event) => {
        event.preventDefault();
        setIsUploadingDocument(true);
        setDocumentError("");
        setDocumentFeedback("");
        try {
            const result = await fetchJson(`${API_BASE_URL}/api/customers/${customer.id}/documents`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    jenisDokumen: documentDraft.jenisDokumen,
                    nomorDokumen: documentDraft.nomorDokumen.trim() || undefined,
                    tanggalDokumen: documentDraft.tanggalDokumen,
                    contractId: contract?.id ?? undefined,
                    contractVersionId: documentDraft.contractVersionId ? Number(documentDraft.contractVersionId) : undefined,
                }),
            });
            const actions = Array.isArray(result?.automation?.actions) ? result.automation.actions : [];
            setDocumentFeedback(actions.join(" ") || "Dokumen berhasil diunggah.");
            setDocumentDraft({
                jenisDokumen: "BAK",
                nomorDokumen: "",
                tanggalDokumen: new Date().toISOString().slice(0, 10),
                contractVersionId: "",
            });
            await Promise.all([loadDetail(), onRefreshAll?.()]);
        } catch (requestError) {
            setDocumentError(requestError instanceof Error ? requestError.message : "Terjadi kesalahan saat mengunggah dokumen.");
        } finally {
            setIsUploadingDocument(false);
        }
    };

    const handleRemoveTenantLinks = async () => {
        setIsDeletingLink(true);
        setDeleteError("");
        try {
            const payload = deleteMode === "this"
                ? { mode: "this", ispId: contextIsp?.id }
                : deleteMode === "all"
                    ? { mode: "all" }
                    : { mode: "selected", ispIds: selectedDeleteIspIds };

            await fetchJson(`${API_BASE_URL}/api/customers/${customer.id}/isps/remove`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload),
            });
            setDeleteModalOpen(false);
            await Promise.all([loadDetail(), onRefreshAll?.()]);
        } catch (requestError) {
            setDeleteError(requestError instanceof Error ? requestError.message : "Terjadi kesalahan saat menghapus relasi tenant.");
        } finally {
            setIsDeletingLink(false);
        }
    };

    const tabs = [
        { key: "overview", label: "Overview" },
        { key: "contracts", label: "Contract" },
        { key: "invoices", label: "Invoice" },
        { key: "documents", label: "Documents" },
        { key: "timeline", label: "Timeline" },
    ];

    return (
        <AppShell activeSection="customers" onNavigate={onNavigate}>
            <div className="mx-auto max-w-7xl space-y-8">
                <button className="inline-flex items-center gap-2 rounded-lg bg-surface-container-low px-4 py-2 text-sm font-semibold text-primary transition-colors hover:bg-surface-container" onClick={onBack} type="button">
                    <span className="material-symbols-outlined text-base">arrow_back</span>
                    Kembali ke Customer Page
                </button>

                <section className="rounded-2xl bg-surface-container-lowest p-6 shadow-sm">
                    <div className="flex flex-col justify-between gap-6 xl:flex-row xl:items-start">
                        <div>
                            <p className="text-xs font-black uppercase tracking-widest text-on-surface-variant/60">Tenant Detail</p>
                            <div className="mt-2 flex flex-wrap items-center gap-3">
                                <h1 className="text-3xl font-extrabold text-primary">{tenantName}</h1>
                                <span className={`rounded-full px-3 py-1 text-xs font-bold ${detail?.status === "aktif" ? "bg-emerald-100 text-emerald-700" : "bg-rose-100 text-rose-700"}`}>{detail?.status === "aktif" ? "Aktif" : "Non-aktif"}</span>
                            </div>
                            <p className="mt-2 text-sm text-slate-500">ISP: {isps.length > 0 ? isps.map((item) => item.name).join(", ") : "-"}</p>
                            {contextIsp?.name && <p className="mt-1 text-sm text-slate-500">Dibuka dari grup ISP: {contextIsp.name}</p>}
                        </div>
                        <div className="flex flex-wrap gap-3">
                            <button className="rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-700 transition-colors hover:bg-slate-50" onClick={openVersionEditor} type="button">Ubah Ratio</button>
                            <button className="rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-700 transition-colors hover:bg-slate-50" onClick={() => setDeleteModalOpen(true)} type="button">Hapus Relasi ISP</button>
                            <button className="rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-700 transition-colors hover:bg-slate-50" onClick={onCreateIsp} type="button">Tambah ISP Baru</button>
                            <button className="rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-700 transition-colors hover:bg-slate-50" onClick={() => void Promise.all([loadDetail(), onRefreshAll?.()])} type="button">Refresh</button>
                        </div>
                    </div>
                </section>

                {error && <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm font-medium text-red-700">{error}</div>}
                {isLoading && <div className="rounded-lg border border-slate-200 bg-white px-4 py-3 text-sm font-medium text-slate-600">Memuat detail tenant...</div>}

                <div className="flex gap-6 overflow-x-auto border-b border-slate-200">
                    {tabs.map((tab) => (
                        <button key={tab.key} className={activeTab === tab.key ? "whitespace-nowrap border-b-2 border-primary pb-4 text-sm font-bold text-primary" : "whitespace-nowrap pb-4 text-sm font-medium text-on-surface-variant hover:text-primary"} onClick={() => setActiveTab(tab.key)} type="button">{tab.label}</button>
                    ))}
                </div>

                {activeTab === "overview" && (
                    <div className="space-y-8">
                        <section className="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4">
                            <SummaryCard label="ISP Terkait" value={isps.length} icon="device_hub" />
                            <SummaryCard label="Invoice" value={invoices.length} icon="receipt_long" />
                            <SummaryCard label="Priority To Do" value={todoSummary.counts?.priority ?? 0} icon="priority_high" />
                            <SummaryCard label="Need Action" value={todoSummary.counts?.needAction ?? 0} icon="pending_actions" />
                        </section>

                        <section className="grid grid-cols-1 gap-6 xl:grid-cols-2">
                            {/* Status Kelengkapan Berkas */}
                            <div className="rounded-2xl bg-surface-container-lowest p-6 shadow-sm">
                                <h2 className="mb-4 flex items-center gap-2 text-lg font-bold text-blue-950">
                                    <span className="material-symbols-outlined text-xl">task_alt</span>
                                    Status Kelengkapan Berkas
                                </h2>
                                <div className="space-y-3">
                                    {(todoSummary.priority ?? []).length > 0 && (
                                        <div>
                                            <p className="mb-2 text-xs font-bold uppercase tracking-widest text-red-600">Prioritas Tinggi</p>
                                            {(todoSummary.priority ?? []).map((item) => (
                                                <div key={item.id} className="mb-2 flex items-start gap-3 rounded-lg border border-red-100 bg-red-50/60 px-4 py-3">
                                                    <span className="material-symbols-outlined mt-0.5 text-base text-red-500">error</span>
                                                    <div>
                                                        <p className="text-sm font-semibold text-red-800">{item.title}</p>
                                                        <p className="text-xs text-red-600">{item.message}</p>
                                                        {item.dueDate && <p className="mt-1 text-[10px] text-red-400">Tenggat: {formatDate(item.dueDate)}</p>}
                                                    </div>
                                                </div>
                                            ))}
                                        </div>
                                    )}
                                    {(todoSummary.needAction ?? []).length > 0 && (
                                        <div>
                                            <p className="mb-2 text-xs font-bold uppercase tracking-widest text-amber-600">Perlu Tindakan</p>
                                            {(todoSummary.needAction ?? []).map((item) => (
                                                <div key={item.id} className="mb-2 flex items-start gap-3 rounded-lg border border-amber-100 bg-amber-50/60 px-4 py-3">
                                                    <span className="material-symbols-outlined mt-0.5 text-base text-amber-500">warning</span>
                                                    <div>
                                                        <p className="text-sm font-semibold text-amber-800">{item.title}</p>
                                                        <p className="text-xs text-amber-600">{item.message}</p>
                                                        {item.dueDate && <p className="mt-1 text-[10px] text-amber-400">Tenggat: {formatDate(item.dueDate)}</p>}
                                                    </div>
                                                </div>
                                            ))}
                                        </div>
                                    )}
                                    {(todoSummary.priority ?? []).length === 0 && (todoSummary.needAction ?? []).length === 0 && (
                                        <div className="flex items-center gap-3 rounded-lg border border-emerald-100 bg-emerald-50/60 px-4 py-3">
                                            <span className="material-symbols-outlined text-base text-emerald-500">check_circle</span>
                                            <p className="text-sm font-semibold text-emerald-700">Semua berkas lengkap. Tidak ada tindakan yang perlu dilakukan.</p>
                                        </div>
                                    )}
                                </div>
                            </div>

                            {/* Biaya Aktivasi */}
                            <div className="space-y-6">
                                <div className="rounded-2xl bg-surface-container-lowest p-6 shadow-sm">
                                    <h2 className="mb-4 flex items-center gap-2 text-lg font-bold text-blue-950">
                                        <span className="material-symbols-outlined text-xl">payments</span>
                                        Biaya Aktivasi
                                    </h2>
                                    {detail?.activationFeePaidAt ? (
                                        <div className="flex items-center gap-3 rounded-lg border border-emerald-100 bg-emerald-50/60 px-4 py-3">
                                            <span className="material-symbols-outlined text-base text-emerald-500">check_circle</span>
                                            <div>
                                                <p className="text-sm font-bold text-emerald-700">Selesai</p>
                                                <p className="text-xs text-emerald-600">Dibayar pada {formatDate(detail.activationFeePaidAt)}</p>
                                            </div>
                                        </div>
                                    ) : (
                                        <div className="flex items-center gap-3 rounded-lg border border-amber-100 bg-amber-50/60 px-4 py-3">
                                            <span className="material-symbols-outlined text-base text-amber-500">schedule</span>
                                            <div>
                                                <p className="text-sm font-bold text-amber-700">Menunggu Pembayaran</p>
                                                <p className="text-lg font-black text-amber-800">{formatCurrency(detail?.activationFeeAmount ?? customer.activationFeeAmount)}</p>
                                            </div>
                                        </div>
                                    )}
                                </div>

                                {/* Dokumen Terbaru */}
                                <div className="rounded-2xl bg-surface-container-lowest p-6 shadow-sm">
                                    <h2 className="mb-4 flex items-center gap-2 text-lg font-bold text-blue-950">
                                        <span className="material-symbols-outlined text-xl">description</span>
                                        Dokumen Terbaru
                                    </h2>
                                    {requiredDocuments.length > 0 ? (
                                        <div className="space-y-2">
                                            {requiredDocuments.slice(0, 3).map((doc) => (
                                                <div key={doc.id} className="flex items-center gap-3 rounded-lg border border-slate-100 bg-white px-4 py-3">
                                                    <span className="material-symbols-outlined text-base text-blue-400">article</span>
                                                    <div>
                                                        <p className="text-sm font-semibold text-slate-800">{documentTypeLabelMap[doc.jenisDokumen] || doc.jenisDokumen}</p>
                                                        <p className="text-xs text-slate-500">{doc.nomorDokumen || "-"} • {formatDate(doc.tanggalDokumen)}</p>
                                                    </div>
                                                </div>
                                            ))}
                                        </div>
                                    ) : (
                                        <p className="text-sm text-slate-500">Belum ada dokumen terunggah.</p>
                                    )}
                                </div>
                            </div>
                        </section>

                        <section className="grid grid-cols-1 gap-6 xl:grid-cols-2">
                            {/* Kontrak Berjalan */}
                            <div className="rounded-2xl bg-surface-container-lowest p-6 shadow-sm">
                                <h2 className="mb-4 flex items-center gap-2 text-lg font-bold text-blue-950">
                                    <span className="material-symbols-outlined text-xl">handshake</span>
                                    Kontrak Berjalan
                                </h2>
                                <div className="overflow-x-auto">
                                    <table className="w-full border-collapse">
                                        <thead>
                                            <tr className="border-b border-slate-100">
                                                <th className="px-3 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Nomor kontrak</th>
                                                <th className="px-3 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Periode</th>
                                                <th className="px-3 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Status</th>
                                                <th className="px-3 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">BAK</th>
                                            </tr>
                                        </thead>
                                        <tbody><tr><td className="px-3 py-4 text-sm font-semibold text-slate-800">{contract?.contractNumber ?? "-"}</td><td className="px-3 py-4 text-sm text-slate-600">{formatContractPeriod(contract?.startDate, contract?.endDate)}</td><td className="px-3 py-4 text-sm text-slate-600">{contract?.status ?? "-"}</td><td className="px-3 py-4 text-sm text-slate-600">{versions[0]?.bakDocumentId ? `#${versions[0].bakDocumentId}` : "Belum ada BAK"}</td></tr></tbody>
                                    </table>
                                </div>
                            </div>

                            {/* Aktivitas Terbaru */}
                            <div className="rounded-2xl bg-surface-container-lowest p-6 shadow-sm">
                                <h2 className="mb-4 flex items-center gap-2 text-lg font-bold text-blue-950">
                                    <span className="material-symbols-outlined text-xl">history</span>
                                    Aktivitas Terbaru
                                </h2>
                                {timeline.length > 0 ? (
                                    <div className="space-y-3">
                                        {timeline.slice(0, 5).map((event) => (
                                            <div key={event.id} className="flex gap-3 rounded-lg border border-slate-100 bg-white px-4 py-3">
                                                <div className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-full ${timelineColorMap[event.type] ?? "text-slate-700 bg-slate-100"}`}>
                                                    <span className="material-symbols-outlined text-sm">{timelineIconMap[event.type] ?? "history"}</span>
                                                </div>
                                                <div>
                                                    <p className="text-sm font-semibold text-slate-800">{event.title}</p>
                                                    <p className="text-xs text-slate-500">{event.description}</p>
                                                    <p className="mt-1 text-[10px] text-slate-400">{formatDate(event.date)}</p>
                                                </div>
                                            </div>
                                        ))}
                                    </div>
                                ) : (
                                    <p className="text-sm text-slate-500">Belum ada aktivitas tercatat.</p>
                                )}
                            </div>
                        </section>
                    </div>
                )}

                {activeTab === "contracts" && (
                    <section className="rounded-2xl bg-surface-container-lowest p-6 shadow-sm">
                        <div className="mb-4 flex items-center justify-between gap-3">
                            <h2 className="text-lg font-bold text-blue-950">Riwayat Perubahan</h2>
                            <button className="rounded-lg bg-primary/5 px-4 py-2 text-sm font-semibold text-primary transition-colors hover:bg-primary/10" onClick={openVersionEditor} type="button">Tambah Perubahan Ratio</button>
                        </div>
                        <div className="overflow-x-auto">
                            <table className="w-full border-collapse">
                                <thead>
                                    <tr className="border-b border-slate-100">
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Versi</th>
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Periode</th>
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Ratio</th>
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">BAK</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-slate-100">
                                    {versions.map((version) => <tr key={version.id}><td className="px-4 py-3 text-sm font-semibold text-slate-800">#{version.versionNumber}</td><td className="px-4 py-3 text-sm text-slate-600">{formatContractPeriod(version.startDate, version.endDate)}</td><td className="px-4 py-3 text-sm text-slate-600">{version.sharedCoreRatio || "-"}</td><td className="px-4 py-3 text-sm text-slate-600">{version.bakDocumentId ? `Tersedia (#${version.bakDocumentId})` : "Belum upload"}</td></tr>)}
                                </tbody>
                            </table>
                        </div>
                    </section>
                )}

                {activeTab === "invoices" && (
                    <section className="rounded-2xl bg-surface-container-lowest p-6 shadow-sm">
                        <h2 className="mb-4 text-lg font-bold text-blue-950">Invoice Tenant</h2>
                        <div className="overflow-x-auto">
                            <table className="w-full border-collapse">
                                <thead>
                                    <tr className="border-b border-slate-100">
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Invoice</th>
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Periode</th>
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Status</th>
                                        <th className="px-4 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Due date</th>
                                        <th className="px-4 py-3 text-right text-[11px] font-black uppercase tracking-wider text-slate-500">Nilai</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-slate-100">
                                    {invoices.map((invoice) => <tr key={invoice.id}><td className="px-4 py-3 text-sm font-semibold text-slate-800">{invoice.invoiceNumber || `#${invoice.id}`}</td><td className="px-4 py-3 text-sm text-slate-600">{formatContractPeriod(invoice.periodStartDate, invoice.periodEndDate)}</td><td className="px-4 py-3 text-sm text-slate-600">{invoiceStatusLabelMap[invoice.status] || invoice.status}</td><td className="px-4 py-3 text-sm text-slate-600">{formatDate(invoice.dueDate)}</td><td className="px-4 py-3 text-right text-sm font-semibold text-slate-700">{formatCurrency(invoice.amount)}</td></tr>)}
                                </tbody>
                            </table>
                        </div>
                    </section>
                )}

                {activeTab === "documents" && (
                    <div className="grid grid-cols-1 gap-6 xl:grid-cols-[1.2fr_0.8fr]">
                        <section className="rounded-2xl bg-surface-container-lowest p-6 shadow-sm">
                            <h2 className="mb-4 text-lg font-bold text-blue-950">Dokumen Tenant</h2>
                            <div className="space-y-3">
                                {requiredDocuments.map((document) => <div key={document.id} className="rounded-xl border border-slate-100 bg-white px-4 py-3"><p className="text-sm font-semibold text-slate-800">{documentTypeLabelMap[document.jenisDokumen] || document.jenisDokumen}</p><p className="mt-1 text-xs text-slate-500">{document.nomorDokumen || "-"} • {formatDate(document.tanggalDokumen)}</p></div>)}
                                {requiredDocuments.length === 0 && <p className="text-sm text-slate-500">Dokumen wajib tenant belum tersedia.</p>}
                            </div>
                        </section>
                        <section className="rounded-2xl bg-surface-container-lowest p-6 shadow-sm">
                            <h2 className="mb-4 text-lg font-bold text-blue-950">Upload Dokumen</h2>
                            <form className="space-y-4" onSubmit={handleUploadDocument}>
                                <FieldSelect label="Jenis Dokumen" value={documentDraft.jenisDokumen} onChange={(value) => setDocumentDraft((previous) => ({ ...previous, jenisDokumen: value }))} options={[{ value: "BAK", label: "BAK" }, { value: "penawaran", label: "Surat penawaran" }, { value: "tanggapan", label: "Surat tanggapan" }, { value: "hasil_nego", label: "Surat negosiasi" }, { value: "invoice", label: "Invoice" }]} />
                                <FieldInput label="Nomor Dokumen" value={documentDraft.nomorDokumen} onChange={(value) => setDocumentDraft((previous) => ({ ...previous, nomorDokumen: value }))} />
                                <FieldInput label="Tanggal Dokumen" type="date" value={documentDraft.tanggalDokumen} onChange={(value) => setDocumentDraft((previous) => ({ ...previous, tanggalDokumen: value }))} />
                                {documentDraft.jenisDokumen === "BAK" && <FieldSelect label="Contract Version" value={documentDraft.contractVersionId} onChange={(value) => setDocumentDraft((previous) => ({ ...previous, contractVersionId: value }))} options={[{ value: "", label: "Pilih versi kontrak" }, ...versions.map((version) => ({ value: String(version.id), label: `Versi ${version.versionNumber} • ${version.sharedCoreRatio || "-"}` }))]} />}
                                {documentError && <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm font-medium text-red-700">{documentError}</div>}
                                {documentFeedback && <div className="rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm font-medium text-emerald-700">{documentFeedback}</div>}
                                <button className="rounded-lg bg-primary px-4 py-2 text-sm font-semibold text-white transition-opacity hover:opacity-90 disabled:cursor-not-allowed disabled:opacity-60" disabled={isUploadingDocument} type="submit">{isUploadingDocument ? "Mengunggah..." : "Simpan Dokumen"}</button>
                            </form>
                        </section>
                    </div>
                )}

                {activeTab === "timeline" && (
                    <section className="rounded-2xl bg-surface-container-lowest p-6 shadow-sm">
                        <h2 className="mb-4 text-lg font-bold text-blue-950">Timeline</h2>
                        <div className="space-y-4">
                            {timeline.map((event) => <div key={event.id} className="flex gap-4 rounded-xl border border-slate-100 bg-white p-4"><div className={`flex h-11 w-11 items-center justify-center rounded-full ${timelineColorMap[event.type] ?? "text-slate-700 bg-slate-100"}`}><span className="material-symbols-outlined text-base">{timelineIconMap[event.type] ?? "history"}</span></div><div><p className="text-sm font-semibold text-slate-800">{event.title}</p><p className="mt-1 text-sm text-slate-500">{event.description}</p><p className="mt-2 text-xs text-slate-400">{formatDate(event.date)}</p></div></div>)}
                        </div>
                    </section>
                )}

                {versionEditor && (
                    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/20 px-4">
                        <div className="w-full max-w-lg rounded-2xl border border-slate-100 bg-white p-6 shadow-2xl">
                            <div className="mb-4 flex items-start justify-between gap-4">
                                <div><p className="text-xs font-black uppercase tracking-widest text-primary">Riwayat Perubahan</p><h3 className="text-xl font-bold text-on-surface">{tenantName}</h3><p className="text-xs text-on-surface-variant">Kontrak tetap satu baris, perubahan ratio dibuat sebagai version baru.</p></div>
                                <button className="rounded-lg bg-slate-100 p-2 text-slate-500 transition-colors hover:bg-slate-200" onClick={() => setVersionEditor(null)} type="button"><span className="material-symbols-outlined text-base">close</span></button>
                            </div>
                            <form className="space-y-4" onSubmit={handleCreateVersion}>
                                <FieldInput label="Shared Core Ratio" value={versionEditor.ratio} onChange={(value) => setVersionEditor((previous) => previous ? { ...previous, ratio: value } : previous)} />
                                <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                                    <FieldInput label="Start Date" type="date" value={versionEditor.startDate} onChange={(value) => setVersionEditor((previous) => previous ? { ...previous, startDate: value } : previous)} />
                                    <FieldInput label="End Date" type="date" value={versionEditor.endDate} onChange={(value) => setVersionEditor((previous) => previous ? { ...previous, endDate: value } : previous)} />
                                </div>
                                {versionError && <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm font-medium text-red-700">{versionError}</div>}
                                <div className="flex justify-end gap-2">
                                    <button className="rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-600 transition-colors hover:bg-slate-50" onClick={() => setVersionEditor(null)} type="button">Batal</button>
                                    <button className="rounded-lg bg-primary px-4 py-2 text-sm font-semibold text-white transition-opacity hover:opacity-90 disabled:cursor-not-allowed disabled:opacity-60" disabled={isSubmittingVersion} type="submit">{isSubmittingVersion ? "Menyimpan..." : "Simpan Perubahan"}</button>
                                </div>
                            </form>
                        </div>
                    </div>
                )}

                {deleteModalOpen && (
                    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/20 px-4">
                        <div className="w-full max-w-xl rounded-2xl border border-slate-100 bg-white p-6 shadow-2xl">
                            <div className="mb-4"><p className="text-xs font-black uppercase tracking-widest text-primary">Delete Tenant Logic</p><h3 className="text-xl font-bold text-on-surface">{tenantName}</h3></div>
                            <div className="space-y-3">
                                <label className="flex items-start gap-3 rounded-xl border border-slate-200 p-4"><input checked={deleteMode === "this"} disabled={!contextIsp?.id} onChange={() => setDeleteMode("this")} type="radio" /><div><p className="text-sm font-semibold text-slate-800">Remove from this ISP only</p><p className="text-xs text-slate-500">{contextIsp?.name ? `Lepas dari ${contextIsp.name}.` : "Hanya tersedia jika tenant dibuka dari detail ISP."}</p></div></label>
                                <label className="flex items-start gap-3 rounded-xl border border-slate-200 p-4"><input checked={deleteMode === "all"} onChange={() => setDeleteMode("all")} type="radio" /><div><p className="text-sm font-semibold text-slate-800">Remove from all ISP</p><p className="text-xs text-slate-500">Lepas tenant dari seluruh grouping ISP.</p></div></label>
                                <label className="flex items-start gap-3 rounded-xl border border-slate-200 p-4"><input checked={deleteMode === "selected"} onChange={() => setDeleteMode("selected")} type="radio" /><div className="w-full"><p className="text-sm font-semibold text-slate-800">Select ISP(s)</p><div className="mt-3 grid grid-cols-1 gap-2 md:grid-cols-2">{isps.map((ispItem) => <label key={ispItem.id} className="flex items-center gap-2 text-sm text-slate-700"><input checked={selectedDeleteIspIds.includes(ispItem.id)} disabled={deleteMode !== "selected"} onChange={() => setSelectedDeleteIspIds((previous) => previous.includes(ispItem.id) ? previous.filter((value) => value !== ispItem.id) : [...previous, ispItem.id])} type="checkbox" />{ispItem.name}</label>)}</div></div></label>
                            </div>
                            {deleteError && <div className="mt-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm font-medium text-red-700">{deleteError}</div>}
                            <div className="mt-6 flex justify-end gap-2">
                                <button className="rounded-lg border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-600 transition-colors hover:bg-slate-50" onClick={() => setDeleteModalOpen(false)} type="button">Batal</button>
                                <button className="rounded-lg bg-red-600 px-4 py-2 text-sm font-semibold text-white transition-opacity hover:opacity-90 disabled:cursor-not-allowed disabled:opacity-60" disabled={isDeletingLink || (deleteMode === "selected" && selectedDeleteIspIds.length === 0)} onClick={() => void handleRemoveTenantLinks()} type="button">{isDeletingLink ? "Memproses..." : "Lanjutkan"}</button>
                            </div>
                        </div>
                    </div>
                )}
            </div>
        </AppShell>
    );
}

function SummaryCard({ label, value, icon }) {
    return (
        <div className="rounded-xl border border-slate-100 bg-white p-5 shadow-sm">
            <div className="flex items-center justify-between gap-4">
                <div>
                    <p className="text-xs font-black uppercase tracking-widest text-on-surface-variant/60">
                        {label}
                    </p>
                    <p className="mt-3 text-3xl font-extrabold text-on-surface">{value}</p>
                </div>
                <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-blue-50 text-primary">
                    <span className="material-symbols-outlined">{icon}</span>
                </div>
            </div>
        </div>
    );
}

function TodoColumn({ title, items }) {
    return (
        <div className="rounded-xl border border-slate-100 bg-white p-4">
            <p className="text-xs font-black uppercase tracking-widest text-slate-500">{title}</p>
            <div className="mt-3 space-y-3">
                {items.length > 0 ? items.map((item) => (
                    <div key={item.id} className="rounded-lg bg-slate-50 px-3 py-3">
                        <p className="text-sm font-semibold text-slate-800">{item.title}</p>
                        <p className="mt-1 text-xs leading-relaxed text-slate-500">{item.message}</p>
                    </div>
                )) : (
                    <p className="text-sm text-slate-500">Tidak ada item.</p>
                )}
            </div>
        </div>
    );
}

function FieldInput({ label, type = "text", value, onChange, placeholder = "" }) {
    return (
        <div>
            <label className="mb-2 block text-xs font-bold uppercase tracking-wider text-on-surface-variant">
                {label}
            </label>
            <input
                className="w-full rounded-lg border-none bg-surface p-3 text-sm focus:ring-2 focus:ring-primary/20"
                onChange={(event) => onChange(event.target.value)}
                placeholder={placeholder}
                type={type}
                value={value}
            />
        </div>
    );
}

function FieldSelect({ label, value, onChange, options }) {
    return (
        <div>
            <label className="mb-2 block text-xs font-bold uppercase tracking-wider text-on-surface-variant">
                {label}
            </label>
            <select
                className="w-full rounded-lg border-none bg-surface p-3 text-sm focus:ring-2 focus:ring-primary/20"
                onChange={(event) => onChange(event.target.value)}
                value={value}
            >
                {options.map((option) => (
                    <option key={`${label}-${option.value}`} value={option.value}>
                        {option.label}
                    </option>
                ))}
            </select>
        </div>
    );
}

function ComplianceItem({ active, label }) {
    return (
        <div className="flex items-center justify-between rounded-lg bg-surface-container-low px-4 py-3">
            <span className="text-sm font-medium text-on-surface">{label}</span>
            <span
                className={`inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-xs font-bold ${active ? "bg-emerald-100 text-emerald-700" : "bg-red-100 text-red-700"
                    }`}
            >
                <span className="material-symbols-outlined text-sm">
                    {active ? "check_circle" : "cancel"}
                </span>
                {active ? "OK" : "Perlu Tindak Lanjut"}
            </span>
        </div>
    );
}

export default App;
