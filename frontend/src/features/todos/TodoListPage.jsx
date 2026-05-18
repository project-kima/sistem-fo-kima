import React, { useCallback, useEffect, useMemo, useState } from "react";
import AppShell from "../../components/layout/AppShell";
import api from "../../lib/api";

const TYPE_LABELS = {
    contract_expiring: "Kontrak",
    contract_admin: "Kontrak",
    invoice_attention: "Invoice",
    invoice_setup: "Invoice",
    invoice_reminder: "Invoice",
    route_attention: "Jalur",
    route_setup: "Jalur",
    activation_fee: "Aktivasi",
    payment_overdue: "Invoice",
    invoice_not_uploaded: "Invoice",
    isp_contract: "Kontrak ISP",
    isp_document: "Dokumen ISP",
};

const SEVERITY_LABELS = {
    critical: "Critical",
    warning: "Warning",
    info: "Info",
};

const SEVERITY_CLASS = {
    critical: "bg-rose-500/10 text-rose-500 border-rose-500/20",
    warning: "bg-amber-500/10 text-amber-500 border-amber-500/20",
    info: "bg-blue-500/10 text-blue-400 border-blue-500/20",
};

const TYPE_ICON = {
    contract_expiring: "event_busy",
    contract_admin: "description",
    invoice_attention: "receipt_long",
    invoice_setup: "edit_calendar",
    invoice_reminder: "notification_important",
    route_attention: "route",
    route_setup: "add_road",
    activation_fee: "payments",
    isp_contract: "assignment",
    isp_document: "upload_file",
};

const formatDate = (value) => {
    if (!value) return "-";
    return new Date(value).toLocaleString("id-ID", {
        day: "2-digit",
        month: "long",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit",
    });
};

const getStatusKey = (notification) => {
    if (notification.resolvedAt) return "resolved";
    if (notification.readAt) return "read";
    return "unread";
};

const getTypeLabel = (notification) => TYPE_LABELS[notification.type] || TYPE_LABELS[notification.code] || notification.type || "Umum";

export default function TodoListPage({ activeSection, onNavigate, onLogout, currentRole = "admin" }) {
    const [notifications, setNotifications] = useState([]);
    const [search, setSearch] = useState("");
    const [severity, setSeverity] = useState("all");
    const [type, setType] = useState("all");
    const [status, setStatus] = useState("active");
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState("");

    const loadNotifications = useCallback(async () => {
        setIsLoading(true);
        setError("");
        try {
            const data = await api.notifications.list({ limit: 200, includeResolved: true });
            setNotifications(Array.isArray(data) ? data : []);
        } catch (err) {
            console.error("Failed to load todo notifications:", err);
            setError(err instanceof Error ? err.message : "Gagal memuat To Do List.");
        } finally {
            setIsLoading(false);
        }
    }, []);

    useEffect(() => {
        loadNotifications();
    }, [loadNotifications]);

    const counts = useMemo(() => notifications.reduce((accumulator, notification) => {
        const key = getStatusKey(notification);
        accumulator.total += 1;
        accumulator[key] += 1;
        if (!notification.resolvedAt) accumulator.active += 1;
        return accumulator;
    }, { total: 0, active: 0, unread: 0, read: 0, resolved: 0 }), [notifications]);

    const typeOptions = useMemo(() => {
        const values = new Map();
        notifications.forEach((notification) => {
            const key = notification.type || notification.code || "general";
            values.set(key, getTypeLabel(notification));
        });
        return Array.from(values.entries()).sort((left, right) => left[1].localeCompare(right[1]));
    }, [notifications]);

    const filteredNotifications = useMemo(() => {
        const normalizedSearch = search.trim().toLowerCase();
        return notifications.filter((notification) => {
            const haystack = [
                notification.title,
                notification.message,
                notification.customerName,
                notification.code,
                notification.type,
            ].filter(Boolean).join(" ").toLowerCase();
            const statusKey = getStatusKey(notification);
            const matchesSearch = !normalizedSearch || haystack.includes(normalizedSearch);
            const matchesSeverity = severity === "all" || notification.severity === severity;
            const matchesType = type === "all" || notification.type === type || notification.code === type;
            const matchesStatus = status === "all"
                || (status === "active" && !notification.resolvedAt)
                || statusKey === status;
            return matchesSearch && matchesSeverity && matchesType && matchesStatus;
        });
    }, [notifications, search, severity, status, type]);

    const openNotification = async (notification) => {
        if (!notification.readAt) {
            await api.notifications.markRead(notification.id);
            await loadNotifications();
        }
        if (notification.targetPath) {
            window.history.pushState({}, "", notification.targetPath);
            window.dispatchEvent(new PopStateEvent("popstate"));
        }
    };

    const markRead = async (notification) => {
        await api.notifications.markRead(notification.id);
        await loadNotifications();
    };

    const markResolved = async (notification) => {
        await api.notifications.markResolved(notification.id);
        await loadNotifications();
    };

    return (
        <AppShell activeSection={activeSection} onNavigate={onNavigate} onLogout={onLogout} currentRole={currentRole}>
            <div className="space-y-6 pb-20 pt-2 md:pt-4">
                <header className="flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between mb-10">
                    <div>
                        <div className="flex items-center gap-3 mb-2">
                            <span className="h-[2px] w-8 bg-gold-accent shadow-gold-glow"></span>
                            <p className="text-[10px] font-black text-gold-accent uppercase tracking-[0.4em]">Pusat Tindakan</p>
                        </div>
                        <h1 className="text-3xl md:text-4xl xl:text-5xl font-black text-on-surface tracking-tight leading-tight">
                            To Do <span className="text-gold-accent italic">List</span>
                        </h1>
                        <p className="mt-3 max-w-2xl text-sm font-bold text-white/40">
                            Kelola semua notifikasi operasional yang perlu dibaca atau ditindaklanjuti.
                        </p>
                    </div>
                    <button
                        className="h-12 rounded-xl border border-white/10 bg-white/5 px-6 text-[10px] font-black uppercase tracking-widest text-white/60 transition-all hover:bg-white/10 hover:text-white disabled:opacity-50"
                        onClick={loadNotifications}
                        disabled={isLoading}
                        type="button"
                    >
                        <span className={`material-symbols-outlined mr-2 align-middle text-base ${isLoading ? "animate-spin" : ""}`}>sync</span>
                        Refresh
                    </button>
                </header>

                <section className="grid grid-cols-2 gap-4 lg:grid-cols-4">
                    {[
                        ["Aktif", counts.active, "task_alt"],
                        ["Belum Dibaca", counts.unread, "mark_email_unread"],
                        ["Dibaca", counts.read, "drafts"],
                        ["Selesai", counts.resolved, "check_circle"],
                    ].map(([label, value, icon]) => (
                        <div key={label} className="rounded-2xl border border-white/10 bg-white/10 p-5 shadow-glass-depth backdrop-blur-xl">
                            <div className="mb-4 flex items-center justify-between">
                                <p className="text-[10px] font-black uppercase tracking-widest text-white/40">{label}</p>
                                <span className="material-symbols-outlined text-gold-accent">{icon}</span>
                            </div>
                            <p className="text-3xl font-black text-white">{value}</p>
                        </div>
                    ))}
                </section>

                <section className="rounded-premium border border-white/10 bg-white/10 p-5 shadow-glass-depth backdrop-blur-xl">
                    <div className="grid gap-4 lg:grid-cols-[1.5fr_0.8fr_0.8fr_0.8fr]">
                        <input
                            type="text"
                            placeholder="Cari pelanggan, pesan, atau kode..."
                            className="h-12 rounded-xl border border-white/10 bg-black/20 px-4 text-xs font-bold text-white outline-none placeholder:text-white/20 focus:border-gold-accent/40"
                            value={search}
                            onChange={(event) => setSearch(event.target.value)}
                        />
                        <select
                            className="h-12 rounded-xl border border-white/10 bg-black/20 px-4 text-xs font-bold text-white outline-none focus:border-gold-accent/40"
                            value={type}
                            onChange={(event) => setType(event.target.value)}
                        >
                            <option value="all" className="bg-[#0f141e]">Semua Tipe</option>
                            {typeOptions.map(([value, label]) => (
                                <option key={value} value={value} className="bg-[#0f141e]">{label}</option>
                            ))}
                        </select>
                        <select
                            className="h-12 rounded-xl border border-white/10 bg-black/20 px-4 text-xs font-bold text-white outline-none focus:border-gold-accent/40"
                            value={severity}
                            onChange={(event) => setSeverity(event.target.value)}
                        >
                            <option value="all" className="bg-[#0f141e]">Semua Severity</option>
                            {Object.entries(SEVERITY_LABELS).map(([value, label]) => (
                                <option key={value} value={value} className="bg-[#0f141e]">{label}</option>
                            ))}
                        </select>
                        <select
                            className="h-12 rounded-xl border border-white/10 bg-black/20 px-4 text-xs font-bold text-white outline-none focus:border-gold-accent/40"
                            value={status}
                            onChange={(event) => setStatus(event.target.value)}
                        >
                            <option value="active" className="bg-[#0f141e]">Aktif</option>
                            <option value="unread" className="bg-[#0f141e]">Belum Dibaca</option>
                            <option value="read" className="bg-[#0f141e]">Dibaca</option>
                            <option value="resolved" className="bg-[#0f141e]">Selesai</option>
                            <option value="all" className="bg-[#0f141e]">Semua Status</option>
                        </select>
                    </div>
                </section>

                <section className="rounded-premium border border-white/10 bg-white/10 p-6 md:p-8 shadow-glass-depth backdrop-blur-xl">
                    <div className="mb-6 flex items-center justify-between">
                        <h2 className="text-xl font-black uppercase tracking-widest text-white">Daftar Tindakan</h2>
                        <span className="rounded-xl border border-white/10 bg-white/5 px-4 py-2 text-[10px] font-black uppercase tracking-widest text-gold-accent">
                            {filteredNotifications.length} Item
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
                            <p className="text-sm font-bold uppercase tracking-widest text-white/40">Memuat To Do List...</p>
                        </div>
                    ) : filteredNotifications.length > 0 ? (
                        <div className="space-y-4">
                            {filteredNotifications.map((notification) => {
                                const severityClass = SEVERITY_CLASS[notification.severity] || SEVERITY_CLASS.info;
                                const statusKey = getStatusKey(notification);
                                return (
                                    <div key={notification.id} className={`rounded-2xl border border-white/10 bg-white/5 p-5 transition-all hover:bg-white/10 ${notification.resolvedAt ? "opacity-60" : ""}`}>
                                        <div className="flex flex-col gap-5 lg:flex-row lg:items-start lg:justify-between">
                                            <div className="flex items-start gap-5">
                                                <div className={`flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl border ${severityClass}`}>
                                                    <span className="material-symbols-outlined text-2xl">{TYPE_ICON[notification.type] || "task_alt"}</span>
                                                </div>
                                                <div>
                                                    <div className="mb-2 flex flex-wrap items-center gap-3">
                                                        <h3 className="text-base font-black text-white">{notification.title}</h3>
                                                        {!notification.readAt && <span className="h-2 w-2 rounded-full bg-gold-accent shadow-gold-glow"></span>}
                                                        <span className={`rounded-lg border px-3 py-1 text-[9px] font-black uppercase tracking-[0.15em] ${severityClass}`}>
                                                            {SEVERITY_LABELS[notification.severity] || notification.severity}
                                                        </span>
                                                        <span className="rounded-lg border border-white/10 bg-white/5 px-3 py-1 text-[9px] font-black uppercase tracking-[0.15em] text-white/50">
                                                            {statusKey === "resolved" ? "Selesai" : statusKey === "read" ? "Dibaca" : "Belum Dibaca"}
                                                        </span>
                                                    </div>
                                                    <p className="max-w-3xl text-sm font-bold leading-relaxed text-white/70">{notification.message}</p>
                                                    <div className="mt-3 flex flex-wrap gap-x-4 gap-y-2 text-[10px] font-black uppercase tracking-widest text-white/35">
                                                        <span>{getTypeLabel(notification)}</span>
                                                        <span>{notification.customerName || "-"}</span>
                                                        <span>Dibuat: {formatDate(notification.createdAt)}</span>
                                                        {notification.readAt && <span>Dibaca: {formatDate(notification.readAt)}</span>}
                                                        {notification.resolvedAt && <span>Selesai: {formatDate(notification.resolvedAt)}</span>}
                                                    </div>
                                                </div>
                                            </div>
                                            <div className="flex flex-wrap items-center justify-end gap-2">
                                                <button
                                                    className="rounded-xl border border-gold-accent/20 bg-gold-accent/10 px-4 py-3 text-[10px] font-black uppercase tracking-widest text-gold-accent transition-all hover:bg-gold-accent hover:text-black"
                                                    onClick={() => openNotification(notification)}
                                                    type="button"
                                                >
                                                    {notification.actionLabel || "Buka"}
                                                </button>
                                                {!notification.readAt && (
                                                    <button
                                                        className="rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-[10px] font-black uppercase tracking-widest text-white/50 transition-all hover:bg-white/10 hover:text-white"
                                                        onClick={() => markRead(notification)}
                                                        type="button"
                                                    >
                                                        Dibaca
                                                    </button>
                                                )}
                                                {!notification.resolvedAt && (
                                                    <button
                                                        className="rounded-xl border border-emerald-500/20 bg-emerald-500/10 px-4 py-3 text-[10px] font-black uppercase tracking-widest text-emerald-400 transition-all hover:bg-emerald-500 hover:text-white"
                                                        onClick={() => markResolved(notification)}
                                                        type="button"
                                                    >
                                                        Selesai
                                                    </button>
                                                )}
                                            </div>
                                        </div>
                                    </div>
                                );
                            })}
                        </div>
                    ) : (
                        <div className="flex flex-col items-center justify-center py-20">
                            <div className="mb-6 flex h-24 w-24 items-center justify-center rounded-3xl border border-white/10 bg-white/5 text-white/20">
                                <span className="material-symbols-outlined text-6xl">task_alt</span>
                            </div>
                            <h3 className="mb-2 text-xl font-black uppercase tracking-widest text-white">Tidak Ada To Do</h3>
                            <p className="text-sm font-bold text-white/30">Tidak ada tindakan yang cocok dengan filter saat ini.</p>
                        </div>
                    )}
                </section>
            </div>
        </AppShell>
    );
}
