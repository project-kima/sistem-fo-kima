import React, { useState } from "react";
import AppShell from "../../components/layout/AppShell";
import { formatDate } from "../../app/utils";

const MOCK_TRASH_ITEMS = [
    { id: 1, name: "PT Telekomunikasi Indonesia", type: "ISP", origin: "Direktori / Mitran ISP", deletedAt: "2026-05-08T10:30:00Z" },
    { id: 2, name: "Jalur FO - Segmen A1", type: "Jalur", origin: "Telkom / Makassar / Jalur", deletedAt: "2026-05-08T09:15:00Z" },
    { id: 3, name: "Gudang Logistik Utama", type: "Lokasi", origin: "Telkom / Makassar / Ringkasan", deletedAt: "2026-05-07T14:20:00Z" },
    { id: 4, name: "KTR-2026-001-KIMA", type: "Kontrak", origin: "Icon+ / Jakarta / Kontrak", deletedAt: "2026-05-07T11:45:00Z" },
    { id: 5, name: "INV/2026/04/0023", type: "Invoice", origin: "Indosat / Surabaya / Billing", deletedAt: "2026-05-06T16:10:00Z" },
    { id: 6, name: "BAK-Instalasi-01.pdf", type: "Dokumen", origin: "Telkom / Makassar / Dokumen", deletedAt: "2026-05-06T08:55:00Z" },
];

const TYPE_CONFIG = {
    ISP: { icon: "corporate_fare", color: "text-blue-400", bg: "bg-blue-400/10" },
    Jalur: { icon: "route", color: "text-indigo-400", bg: "bg-indigo-400/10" },
    Lokasi: { icon: "location_on", color: "text-amber-400", bg: "bg-amber-400/10" },
    Kontrak: { icon: "article", color: "text-emerald-400", bg: "bg-emerald-400/10" },
    Invoice: { icon: "receipt_long", color: "text-[#FF3B30]", bg: "bg-red-500/10" },
    Dokumen: { icon: "description", color: "text-slate-400", bg: "bg-slate-400/10" },
};

const INITIAL_DELETION_STATS = {
    lastClearedAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000).toISOString(),
    totalItems: 145,
    breakdown: {
        ISP: 5,
        Jalur: 12,
        Lokasi: 3,
        Kontrak: 45,
        Invoice: 60,
        Dokumen: 20
    }
};

export default function TrashPage({ activeSection, onNavigate, currentRole = "admin" }) {
    const isTeknisi = currentRole === "teknisi";
    const [searchQuery, setSearchQuery] = useState("");
    const [trashItems, setTrashItems] = useState(MOCK_TRASH_ITEMS);
    const [deletionStats, setDeletionStats] = useState(INITIAL_DELETION_STATS);

    const filteredItems = trashItems.filter(item => {
        const matchesSearch = item.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
            item.type.toLowerCase().includes(searchQuery.toLowerCase());
        if (isTeknisi) {
            return matchesSearch && item.type === "Jalur";
        }
        return matchesSearch;
    });

    const handleRestore = (id) => {
        setTrashItems(prev => prev.filter(item => item.id !== id));
    };

    const handleDeletePermanently = (id) => {
        const itemToDelete = trashItems.find(item => item.id === id);
        if (!itemToDelete) return;

        if (confirm("Hapus data ini secara permanen?")) {
            setTrashItems(prev => prev.filter(item => item.id !== id));
            setDeletionStats(prev => ({
                lastClearedAt: new Date().toISOString(),
                totalItems: prev.totalItems + 1,
                breakdown: {
                    ...prev.breakdown,
                    [itemToDelete.type]: (prev.breakdown[itemToDelete.type] || 0) + 1
                }
            }));
        }
    };

    return (
        <AppShell activeSection={activeSection} onNavigate={onNavigate} currentRole={currentRole}>
            <div className="space-y-6 pb-20 pt-2 md:pt-4">
                {/* Premium Header Section */}
                <header className="flex flex-col lg:flex-row lg:items-end justify-between gap-6 mb-12">
                    <div>
                        <div className="flex items-center gap-3 mb-2">
                            <span className="h-[2px] w-8 bg-gold-accent shadow-gold-glow"></span>
                            <p className="text-[10px] font-black text-gold-accent uppercase tracking-[0.4em]">Arsip Pembuangan</p>
                        </div>
                        <h1 className="text-3xl md:text-4xl xl:text-5xl font-black text-on-surface tracking-tight leading-tight">
                            Tempat <span className="text-gold-accent italic">Sampah</span>
                        </h1>
                    </div>

                    <div className="flex flex-col md:flex-row items-center gap-4 w-full lg:w-auto">
                        <div className="relative w-full md:w-80 group">
                            <span className="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-white/30 group-focus-within:text-gold-accent transition-colors">
                                search
                            </span>
                            <input
                                type="text"
                                placeholder="Cari data yang dihapus..."
                                className="w-full rounded-2xl border border-white/10 bg-white/5 py-3 pl-12 pr-4 text-sm font-bold text-white placeholder:text-white/20 outline-none transition-all focus:bg-white/10 focus:border-gold-accent/40 focus:ring-4 focus:ring-gold-accent/5"
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                            />
                        </div>

                        <div className="flex items-center gap-3 w-full lg:w-auto justify-end">
                            {!isTeknisi && (
                                <button
                                    className="inline-flex h-[56px] items-center gap-3 rounded-2xl bg-red-600/20 backdrop-blur-md border border-[#FF3B30]/30 px-8 text-red-50 transition-all hover:bg-red-600/30 hover:border-[#FF3B30]/50 hover:-translate-y-1 hover:shadow-[0_15px_30px_rgba(255,59,48,0.3)] active:scale-95 group shadow-lg"
                                    onClick={() => { if (confirm("Hapus semua sampah secara permanen?")) setTrashItems([]); }}
                                >
                                    <span className="material-symbols-outlined text-xl text-red-50">delete_sweep</span>
                                    <span className="text-[11px] font-black uppercase tracking-widest text-red-50">Hapus Permanen</span>
                                </button>
                            )}

                            <div className="flex items-center gap-2 bg-white/10 p-1.5 rounded-2xl border border-white/15 backdrop-blur-md ml-2">
                                <button
                                    className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl btn-premium active:scale-95 transition-transform"
                                    onClick={() => {
                                        // Mock refresh
                                        const btn = document.activeElement;
                                        btn?.classList.add('animate-spin');
                                        setTimeout(() => btn?.classList.remove('animate-spin'), 1000);
                                    }}
                                    title="Refresh Data"
                                >
                                    <span className="material-symbols-outlined text-xl">sync</span>
                                </button>
                            </div>
                        </div>
                    </div>
                </header>

                {/* Stats Section */}
                <div className="relative overflow-hidden rounded-premium border border-white/10 bg-white/10 backdrop-blur-xl p-8 shadow-glass-depth group">
                    <div className="absolute -right-24 -top-24 h-64 w-64 rounded-full bg-gold-accent/5 blur-3xl transition-all duration-700 group-hover:bg-gold-accent/10" />

                    <div className="relative flex flex-col md:flex-row md:items-center justify-between gap-10">
                        <div className="flex items-center gap-6">
                            <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-gold-accent/10 border border-gold-accent/20">
                                <span className="material-symbols-outlined text-3xl text-gold-accent animate-pulse">auto_delete</span>
                            </div>
                            <div>
                                <h2 className="text-xl font-black text-white uppercase tracking-wider">Statistik Pembersihan</h2>
                                <p className="text-xs font-bold text-white/40 mt-1 uppercase tracking-widest leading-relaxed">
                                    Pembersihan Terakhir: <span className="text-gold-accent">{formatDate(deletionStats.lastClearedAt)}</span>
                                </p>
                            </div>
                        </div>

                        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4 flex-1 max-w-4xl">
                            {Object.entries(deletionStats.breakdown).map(([type, count]) => {
                                const config = TYPE_CONFIG[type] || { color: 'text-white/30', bg: 'bg-white/5' };
                                const hoverBorderClass = {
                                    ISP: "hover:border-blue-500/40",
                                    Jalur: "hover:border-indigo-500/40",
                                    Lokasi: "hover:border-amber-500/40",
                                    Kontrak: "hover:border-emerald-500/40",
                                    Invoice: "hover:border-red-500/40",
                                    Dokumen: "hover:border-white/30",
                                }[type] || "hover:border-white/20";

                                return (
                                    <div
                                        key={type}
                                        className={`rounded-2xl bg-white/5 border border-white/10 p-4 transition-all hover:bg-white/10 ${hoverBorderClass} hover:scale-105 hover:shadow-lg active:scale-95 cursor-default group/stat`}
                                    >
                                        <p className={`text-[10px] font-black uppercase tracking-widest mb-1 transition-colors ${config.color} opacity-70 group-hover/stat:opacity-100`}>{type}</p>
                                        <p className="text-xl font-black text-white">{count}</p>
                                    </div>
                                );
                            })}
                        </div>
                    </div>
                </div>

                {/* List Section in Card Container */}
                <div className="rounded-premium p-6 md:p-8 border border-white/10 bg-white/10 backdrop-blur-xl shadow-glass-depth cursor-default">
                    <div className="flex items-center gap-3 mb-8">
                        <h2 className="text-xl font-black text-white uppercase tracking-widest">Daftar Item Terhapus</h2>
                    </div>

                    <div className="space-y-4">
                        {filteredItems.length > 0 ? (
                            <div className="grid grid-cols-1 gap-4">
                                {filteredItems.map((item) => {
                                    const config = TYPE_CONFIG[item.type] || { icon: "article", color: "text-white/30", bg: "bg-white/5" };
                                    const hoverBorderClass = {
                                        ISP: "hover:border-blue-500/40",
                                        Jalur: "hover:border-indigo-500/40",
                                        Lokasi: "hover:border-amber-500/40",
                                        Kontrak: "hover:border-emerald-500/40",
                                        Invoice: "hover:border-red-500/40",
                                        Dokumen: "hover:border-white/30",
                                    }[item.type] || "hover:border-white/20";

                                    return (
                                        <div
                                            key={item.id}
                                            className={`group relative flex flex-col lg:flex-row lg:items-center justify-between gap-6 rounded-2xl bg-white/5 p-6 transition-all hover:bg-white/10 ${hoverBorderClass} hover:shadow-2xl hover:scale-[1.01] backdrop-blur-md overflow-hidden border border-white/10`}
                                        >
                                            <div className="flex items-center gap-6">
                                                <div className={`flex h-14 w-14 items-center justify-center rounded-2xl ${TYPE_CONFIG[item.type]?.bg || 'bg-white/5'} border border-white/5 transition-all group-hover:scale-110`}>
                                                    <span className={`material-symbols-outlined text-2xl ${TYPE_CONFIG[item.type]?.color || 'text-white'}`}>
                                                        {TYPE_CONFIG[item.type]?.icon || 'article'}
                                                    </span>
                                                </div>
                                                <div>
                                                    <div className="flex flex-wrap items-center gap-3 mb-1">
                                                        <h3 className="text-lg font-black text-white tracking-tight leading-none">{item.name}</h3>
                                                        <span className={`rounded-lg px-3 py-1 text-[9px] font-black uppercase tracking-[0.15em] border ${config.color.replace('text-', 'border-')}/40 ${config.bg} ${config.color}`}>
                                                            {item.type}
                                                        </span>
                                                    </div>
                                                    <div className="flex flex-wrap items-center gap-x-4 gap-y-2">
                                                        <div className="flex items-center gap-2">
                                                            <p className="text-[10px] font-bold text-white/70 uppercase tracking-widest shrink-0">Asal:</p>
                                                            <div className="flex items-center gap-1.5 overflow-hidden">
                                                                {item.origin.split(' / ').map((crumb, idx, arr) => (
                                                                    <React.Fragment key={idx}>
                                                                        <span className="text-[10px] font-black uppercase tracking-widest whitespace-nowrap text-gold-accent">
                                                                            {crumb}
                                                                        </span>
                                                                        {idx < arr.length - 1 && <span className="text-white/30 text-[8px]">/</span>}
                                                                    </React.Fragment>
                                                                ))}
                                                            </div>
                                                        </div>
                                                        <div className="h-1 w-1 rounded-full bg-white/20 hidden sm:block" />
                                                        <p className="text-[10px] font-bold text-white/70 uppercase tracking-widest flex items-center gap-1.5">
                                                            <span className="text-[#FF3B30] font-black">{new Date(item.deletedAt).toLocaleString('id-ID', { day: '2-digit', month: 'long', year: 'numeric', hour: '2-digit', minute: '2-digit' })}</span>
                                                        </p>
                                                    </div>
                                                </div>
                                            </div>

                                            <div className="flex items-center gap-3 self-end lg:self-center">
                                                <button
                                                    onClick={() => handleRestore(item.id)}
                                                    className="flex h-11 items-center gap-3 rounded-xl bg-emerald-500/10 border border-emerald-500/20 px-5 text-[10px] font-black uppercase tracking-widest text-emerald-400 transition-all hover:bg-emerald-500 hover:text-white hover:shadow-lg hover:shadow-emerald-500/20 active:scale-95"
                                                >
                                                    <span className="material-symbols-outlined text-lg">restore_from_trash</span>
                                                    Pulihkan
                                                </button>
                                                <button
                                                    onClick={() => handleDeletePermanently(item.id)}
                                                    className="flex h-11 w-11 items-center justify-center rounded-xl bg-red-500/10 border border-red-500/20 text-red-500 transition-all hover:bg-red-500 hover:text-white hover:shadow-lg hover:shadow-red-500/20 active:scale-95"
                                                    title="Hapus Permanen"
                                                >
                                                    <span className="material-symbols-outlined text-lg">delete_forever</span>
                                                </button>
                                            </div>
                                        </div>
                                    );
                                })}
                            </div>
                        ) : (
                            <div className="flex flex-col items-center justify-center py-20 animate-in fade-in zoom-in duration-500">
                                <div className="relative mb-8">
                                    <div className="absolute inset-0 scale-150 bg-white/5 blur-[50px] rounded-full" />
                                    <div className="relative flex h-24 w-24 items-center justify-center rounded-3xl bg-white/5 border border-white/10 shadow-2xl backdrop-blur-xl text-white/20">
                                        <span className="material-symbols-outlined text-6xl">delete_outline</span>
                                    </div>
                                </div>
                                <h3 className="text-xl font-black text-white uppercase tracking-widest mb-3">Tempat Sampah Kosong</h3>
                                <p className="text-sm font-bold text-white/30 tracking-wide">Data yang Anda hapus sementara akan muncul di sini.</p>
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </AppShell>
    );
}
