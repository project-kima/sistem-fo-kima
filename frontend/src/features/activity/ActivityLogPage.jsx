import React, { useCallback, useEffect, useMemo, useState } from "react";
import AppShell from "../../components/layout/AppShell";
import api from "../../lib/api";

const ACTION_LABELS = {
    "customer.created": "Menambahkan pelanggan baru",
    "customer.updated": "Mengubah data pelanggan",
    "customer.status_changed": "Mengubah status pelanggan",
    "customer.deleted": "Menghapus pelanggan",
    "customer.restored": "Memulihkan pelanggan dari Trash",
    "isp.created": "Menambahkan ISP baru",
    "isp.updated": "Mengubah data ISP",
    "isp.deleted": "Menghapus ISP",
    "isp.restored": "Memulihkan ISP dari Trash",
    "contract.restored": "Memulihkan kontrak dari Trash",
    "invoice.restored": "Memulihkan invoice dari Trash",
    "document.restored": "Memulihkan dokumen dari Trash",
    "route.restored": "Memulihkan jalur dari Trash",
};

const ENTITY_LABELS = {
    customer: "Pelanggan",
    isp: "ISP",
    contract: "Kontrak",
    invoice: "Invoice",
    document: "Dokumen",
    route: "Jalur",
};

const ENTITY_CONFIG = {
    customer: { icon: "groups", color: "text-amber-400", bg: "bg-amber-400/10" },
    isp: { icon: "corporate_fare", color: "text-blue-400", bg: "bg-blue-400/10" },
    contract: { icon: "article", color: "text-emerald-400", bg: "bg-emerald-400/10" },
    invoice: { icon: "receipt_long", color: "text-[#ff2400]", bg: "bg-[#ff2400]/10" },
    document: { icon: "description", color: "text-slate-400", bg: "bg-slate-400/10" },
    route: { icon: "route", color: "text-indigo-400", bg: "bg-indigo-400/10" },
};

const formatDateTime = (value) => {
    if (!value) return "-";
    return new Date(value).toLocaleString("id-ID", {
        day: "2-digit",
        month: "long",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit",
    });
};

const getActionLabel = (action) => ACTION_LABELS[action] || action || "Aktivitas";

const formatValue = (value) => {
    if (value === null || value === undefined || value === "") return "-";
    if (typeof value === "object") return JSON.stringify(value, null, 2);
    return String(value);
};

function ChangeSummary({ metadata }) {
    const changedFields = Array.isArray(metadata?.changed_fields) ? metadata.changed_fields : [];
    if (changedFields.length === 0) return null;

    return (
        <div className="space-y-3">
            <p className="text-[10px] font-black uppercase tracking-[0.2em] text-white/30">Perubahan</p>
            <div className="space-y-2">
                {changedFields.map((field) => (
                    <div key={field} className="rounded-xl border border-white/10 bg-black/20 p-4">
                        <p className="mb-2 text-[10px] font-black uppercase tracking-widest text-gold-accent">{field.replaceAll("_", " ")}</p>
                        <div className="grid gap-3 md:grid-cols-2">
                            <div>
                                <p className="mb-1 text-[9px] font-black uppercase tracking-widest text-white/30">Sebelum</p>
                                <p className="text-sm font-bold text-white/70 whitespace-pre-wrap">{formatValue(metadata?.before?.[field])}</p>
                            </div>
                            <div>
                                <p className="mb-1 text-[9px] font-black uppercase tracking-widest text-white/30">Sesudah</p>
                                <p className="text-sm font-bold text-white whitespace-pre-wrap">{formatValue(metadata?.after?.[field])}</p>
                            </div>
                        </div>
                    </div>
                ))}
            </div>
        </div>
    );
}

export default function ActivityLogPage({ activeSection, onNavigate, onLogout, currentRole = "admin" }) {
    const [logs, setLogs] = useState([]);
    const [searchQuery, setSearchQuery] = useState("");
    const [entityType, setEntityType] = useState("");
    const [action, setAction] = useState("");
    const [dateFrom, setDateFrom] = useState("");
    const [dateTo, setDateTo] = useState("");
    const [selectedLog, setSelectedLog] = useState(null);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState("");

    const actionOptions = useMemo(() => Object.entries(ACTION_LABELS), []);

    const loadLogs = useCallback(async () => {
        setIsLoading(true);
        setError("");
        try {
            const data = await api.activityLogs.list({
                search: searchQuery,
                entityType,
                action,
                dateFrom,
                dateTo,
                limit: 150,
            });
            setLogs(data);
        } catch (err) {
            console.error("Failed to load activity logs:", err);
            setError(err instanceof Error ? err.message : "Gagal memuat activity log.");
        } finally {
            setIsLoading(false);
        }
    }, [action, dateFrom, dateTo, entityType, searchQuery]);

    useEffect(() => {
        loadLogs();
    }, [loadLogs]);

    const handleApplyFilter = (event) => {
        event.preventDefault();
        loadLogs();
    };

    return (
        <AppShell activeSection={activeSection} onNavigate={onNavigate} onLogout={onLogout} currentRole={currentRole}>
            <div className="space-y-6 pb-20 pt-2 md:pt-4">
                <header className="flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between mb-10">
                    <div>
                        <div className="flex items-center gap-3 mb-2">
                            <span className="h-[2px] w-8 bg-gold-accent shadow-gold-glow"></span>
                            <p className="text-[10px] font-black text-gold-accent uppercase tracking-[0.4em]">Audit Trail</p>
                        </div>
                        <h1 className="text-3xl md:text-4xl xl:text-5xl font-black text-on-surface tracking-tight leading-tight">
                            Activity <span className="text-gold-accent italic">Log</span>
                        </h1>
                        <p className="mt-3 max-w-2xl text-sm font-bold text-white/40">
                            Pantau perubahan data pelanggan, ISP, dan pemulihan data dari Trash.
                        </p>
                    </div>
                    <button
                        className="h-12 rounded-xl border border-white/10 bg-white/5 px-6 text-[10px] font-black uppercase tracking-widest text-white/60 transition-all hover:bg-white/10 hover:text-white disabled:opacity-50"
                        onClick={loadLogs}
                        disabled={isLoading}
                        type="button"
                    >
                        <span className={`material-symbols-outlined mr-2 align-middle text-base ${isLoading ? "animate-spin" : ""}`}>sync</span>
                        Refresh
                    </button>
                </header>

                <form onSubmit={handleApplyFilter} className="rounded-premium border border-white/10 bg-white/10 p-5 shadow-glass-depth backdrop-blur-xl">
                    <div className="grid gap-4 lg:grid-cols-[1.3fr_0.8fr_1fr_0.7fr_0.7fr_auto]">
                        <input
                            type="text"
                            placeholder="Cari user, aktivitas, atau nama data..."
                            className="h-12 rounded-xl border border-white/10 bg-black/20 px-4 text-xs font-bold text-white outline-none placeholder:text-white/20 focus:border-gold-accent/40"
                            value={searchQuery}
                            onChange={(event) => setSearchQuery(event.target.value)}
                        />
                        <select
                            className="h-12 rounded-xl border border-white/10 bg-black/20 px-4 text-xs font-bold text-white outline-none focus:border-gold-accent/40"
                            value={entityType}
                            onChange={(event) => setEntityType(event.target.value)}
                        >
                            <option value="" className="bg-[#0f141e]">Semua Modul</option>
                            {Object.entries(ENTITY_LABELS).map(([value, label]) => (
                                <option key={value} value={value} className="bg-[#0f141e]">{label}</option>
                            ))}
                        </select>
                        <select
                            className="h-12 rounded-xl border border-white/10 bg-black/20 px-4 text-xs font-bold text-white outline-none focus:border-gold-accent/40"
                            value={action}
                            onChange={(event) => setAction(event.target.value)}
                        >
                            <option value="" className="bg-[#0f141e]">Semua Aktivitas</option>
                            {actionOptions.map(([value, label]) => (
                                <option key={value} value={value} className="bg-[#0f141e]">{label}</option>
                            ))}
                        </select>
                        <input
                            type="date"
                            className="h-12 rounded-xl border border-white/10 bg-black/20 px-4 text-xs font-bold text-white outline-none focus:border-gold-accent/40"
                            value={dateFrom}
                            onChange={(event) => setDateFrom(event.target.value)}
                        />
                        <input
                            type="date"
                            className="h-12 rounded-xl border border-white/10 bg-black/20 px-4 text-xs font-bold text-white outline-none focus:border-gold-accent/40"
                            value={dateTo}
                            onChange={(event) => setDateTo(event.target.value)}
                        />
                        <button
                            className="h-12 rounded-xl bg-gold-accent px-6 text-[10px] font-black uppercase tracking-widest text-black transition-all hover:brightness-110 active:scale-95"
                            type="submit"
                        >
                            Filter
                        </button>
                    </div>
                </form>

                <section className="rounded-premium border border-white/10 bg-white/10 p-6 md:p-8 shadow-glass-depth backdrop-blur-xl">
                    <div className="mb-6 flex items-center justify-between">
                        <h2 className="text-xl font-black uppercase tracking-widest text-white">Riwayat Aktivitas</h2>
                        <span className="rounded-xl border border-white/10 bg-white/5 px-4 py-2 text-[10px] font-black uppercase tracking-widest text-gold-accent">
                            {logs.length} Log
                        </span>
                    </div>

                    {error && (
                        <div className="mb-4 rounded-xl border border-[#ff2400]/20 bg-[#ff2400]/10 p-4 text-sm font-bold text-[#ff2400]">
                            {error}
                        </div>
                    )}

                    {isLoading ? (
                        <div className="flex flex-col items-center justify-center py-20">
                            <div className="mb-4 h-16 w-16 animate-spin rounded-full border-4 border-gold-accent border-t-transparent"></div>
                            <p className="text-sm font-bold uppercase tracking-widest text-white/40">Memuat activity log...</p>
                        </div>
                    ) : logs.length > 0 ? (
                        <div className="space-y-4">
                            {logs.map((log) => {
                                const config = ENTITY_CONFIG[log.entity_type] || { icon: "history", color: "text-white/40", bg: "bg-white/5" };
                                return (
                                    <div key={log.id} className="group flex flex-col gap-5 rounded-2xl border border-white/10 bg-white/5 p-5 transition-all hover:bg-white/10 lg:flex-row lg:items-center lg:justify-between">
                                        <div className="flex items-start gap-5">
                                            <div className={`flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl border border-white/5 ${config.bg}`}>
                                                <span className={`material-symbols-outlined text-2xl ${config.color}`}>{config.icon}</span>
                                            </div>
                                            <div>
                                                <div className="mb-2 flex flex-wrap items-center gap-3">
                                                    <h3 className="text-base font-black text-white">{getActionLabel(log.action)}</h3>
                                                    <span className={`rounded-lg px-3 py-1 text-[9px] font-black uppercase tracking-[0.15em] ${config.bg} ${config.color}`}>
                                                        {ENTITY_LABELS[log.entity_type] || log.entity_type}
                                                    </span>
                                                </div>
                                                <p className="text-sm font-bold text-white/70">{log.entity_name || "-"}</p>
                                                <div className="mt-3 flex flex-wrap gap-x-4 gap-y-2 text-[10px] font-black uppercase tracking-widest text-white/35">
                                                    <span>{formatDateTime(log.created_at)}</span>
                                                    <span>{log.actor_email || "User tidak diketahui"}</span>
                                                    <span>{log.actor_role || "-"}</span>
                                                </div>
                                            </div>
                                        </div>
                                        <button
                                            className="self-end rounded-xl border border-gold-accent/20 bg-gold-accent/10 px-5 py-3 text-[10px] font-black uppercase tracking-widest text-gold-accent transition-all hover:bg-gold-accent hover:text-black lg:self-center"
                                            onClick={() => setSelectedLog(log)}
                                            type="button"
                                        >
                                            Lihat Detail
                                        </button>
                                    </div>
                                );
                            })}
                        </div>
                    ) : (
                        <div className="flex flex-col items-center justify-center py-20">
                            <div className="mb-6 flex h-24 w-24 items-center justify-center rounded-3xl border border-white/10 bg-white/5 text-white/20">
                                <span className="material-symbols-outlined text-6xl">manage_history</span>
                            </div>
                            <h3 className="mb-2 text-xl font-black uppercase tracking-widest text-white">Belum Ada Log</h3>
                            <p className="text-sm font-bold text-white/30">Aktivitas baru akan muncul setelah perubahan data dilakukan.</p>
                        </div>
                    )}
                </section>
            </div>

            {selectedLog && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 p-4 backdrop-blur-sm" onClick={() => setSelectedLog(null)}>
                    <div className="max-h-[90vh] w-full max-w-3xl overflow-y-auto rounded-3xl border border-white/10 bg-[#0f141e] p-6 shadow-2xl" onClick={(event) => event.stopPropagation()}>
                        <div className="mb-6 flex items-start justify-between gap-4">
                            <div>
                                <p className="mb-2 text-[10px] font-black uppercase tracking-[0.3em] text-gold-accent">Detail Activity</p>
                                <h2 className="text-2xl font-black text-white">{getActionLabel(selectedLog.action)}</h2>
                            </div>
                            <button
                                className="flex h-10 w-10 items-center justify-center rounded-xl border border-white/10 bg-white/5 text-white/50 hover:bg-white/10 hover:text-white"
                                onClick={() => setSelectedLog(null)}
                                type="button"
                            >
                                <span className="material-symbols-outlined">close</span>
                            </button>
                        </div>

                        <div className="grid gap-4 md:grid-cols-2 mb-6">
                            {[
                                ["Waktu", formatDateTime(selectedLog.created_at)],
                                ["User", selectedLog.actor_email || "-"],
                                ["Role", selectedLog.actor_role || "-"],
                                ["Modul", ENTITY_LABELS[selectedLog.entity_type] || selectedLog.entity_type],
                                ["Nama Data", selectedLog.entity_name || "-"],
                                ["ID Data", selectedLog.entity_id || "-"],
                            ].map(([label, value]) => (
                                <div key={label} className="rounded-xl border border-white/10 bg-white/5 p-4">
                                    <p className="mb-1 text-[9px] font-black uppercase tracking-widest text-white/30">{label}</p>
                                    <p className="text-sm font-bold text-white">{value}</p>
                                </div>
                            ))}
                        </div>

                        {selectedLog.description && (
                            <div className="mb-6 rounded-xl border border-white/10 bg-white/5 p-4">
                                <p className="mb-1 text-[9px] font-black uppercase tracking-widest text-white/30">Deskripsi</p>
                                <p className="text-sm font-bold text-white">{selectedLog.description}</p>
                            </div>
                        )}

                        <ChangeSummary metadata={selectedLog.metadata || {}} />

                        <div className="mt-6 rounded-xl border border-white/10 bg-black/20 p-4">
                            <p className="mb-3 text-[10px] font-black uppercase tracking-[0.2em] text-white/30">Metadata</p>
                            <pre className="max-h-80 overflow-auto whitespace-pre-wrap text-xs font-semibold text-white/70">
                                {JSON.stringify(selectedLog.metadata || {}, null, 2)}
                            </pre>
                        </div>
                    </div>
                </div>
            )}
        </AppShell>
    );
}
