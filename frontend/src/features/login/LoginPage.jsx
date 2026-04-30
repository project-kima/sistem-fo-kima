import { useMemo, useState } from "react";
import { FieldInput } from "../../components/shared/AppShared";

/**
 * Utility untuk membersihkan nomor WhatsApp
 */
function normalizeWhatsAppNumber(rawNumber) {
    const trimmed = String(rawNumber ?? "").trim();
    if (!trimmed) return "";
    return trimmed.replace(/[\s()+-]/g, "");
}

function buildWhatsAppLink(rawNumber) {
    const normalized = normalizeWhatsAppNumber(rawNumber);
    if (!normalized) return "";
    return `https://wa.me/${normalized}`;
}

export default function LoginPage({ onLoginSuccess }) {
    const [activePanel, setActivePanel] = useState("login");
    const [form, setForm] = useState({
        identifier: "",
        password: "",
    });
    const [error, setError] = useState("");

    const adminWhatsAppNumber = import.meta.env.VITE_ADMIN_WHATSAPP_NUMBER ?? "";
    const adminWhatsAppLink = useMemo(
        () => buildWhatsAppLink(adminWhatsAppNumber),
        [adminWhatsAppNumber],
    );
    const canOpenWhatsApp = Boolean(adminWhatsAppLink);

    const handleSubmit = (event) => {
        event.preventDefault();
        setError("");

        if (!form.identifier.trim()) {
            setError("Email/Username wajib diisi.");
            return;
        }
        if (!form.password) {
            setError("Password wajib diisi.");
            return;
        }

        if (onLoginSuccess) {
            onLoginSuccess({
                identifier: form.identifier.trim(),
                password: form.password,
            });
        }
    };

    return (
        <div
            className="relative min-h-screen w-full flex items-center justify-center overflow-hidden font-sans"
            style={{ 
                backgroundImage: "url(/kima1.jpeg)", 
                backgroundSize: 'cover', 
                backgroundPosition: 'center' 
            }}
        >
            {/* Scrim Overlay */}
            <div className="absolute inset-0 bg-black/40 z-0" />

            {/* Main Card Container */}
            <div className="relative z-10 w-full max-w-[1000px] px-6">
                <div className="relative bg-white/95 backdrop-blur-md rounded-[3.5rem] shadow-2xl overflow-hidden min-h-[600px] grid grid-cols-1 md:grid-cols-2">
                    
                    {/* Garis Kuning Pemisah Tengah (Tebal) */}
                    <div className="absolute left-1/2 top-1/4 bottom-1/4 w-[5px] bg-yellow-400 rounded-full z-10 hidden md:block -translate-x-1/2" />

                    {/* --- AREA KIRI (Bantuan Akses) --- */}
                    <div className="p-12 md:p-16 flex flex-col justify-center bg-slate-50/20">
                        <div className="mb-10">
                            <h3 className="text-3xl font-black text-slate-900 tracking-tight">Bantuan Akses</h3>
                            <p className="text-slate-500 mt-4 text-sm leading-relaxed">
                                Pemulihan akun memerlukan verifikasi Administrator TI. Silakan hubungi unit terkait melalui tautan di bawah ini.
                            </p>
                        </div>
                        <div className="space-y-6">
                            <a
                                href={canOpenWhatsApp ? adminWhatsAppLink : "#"}
                                target="_blank"
                                rel="noreferrer"
                                className="flex items-center justify-center gap-3 w-full py-4 rounded-2xl font-bold text-slate-900 bg-yellow-400 hover:bg-yellow-500 transition-all text-sm active:scale-95"
                            >
                                Hubungi Admin via WhatsApp
                            </a>
                            <button
                                onClick={() => setActivePanel("login")}
                                className="w-full text-xs font-semibold text-slate-400 hover:text-primary transition-colors"
                            >
                                ← Kembali ke Halaman Login
                            </button>
                        </div>
                    </div>

                    {/* --- AREA KANAN (Login Form) --- */}
                    <div className="p-12 md:p-16 flex flex-col justify-center bg-white">
                        <div className="mb-10">
                            <h3 className="text-3xl font-black text-slate-900 tracking-tight">Sign In</h3>
                            <p className="text-slate-400 mt-2 text-sm font-medium">Portal Dokumentasi Digital</p>
                        </div>

                        <form onSubmit={handleSubmit} className="space-y-5">
                            {error && (
                                <div className="flex items-center gap-3 rounded-2xl bg-red-50 p-4 text-[11px] font-bold text-red-600 border border-red-100 animate-shake">
                                    <span className="h-2 w-2 rounded-full bg-red-500 shadow-sm" />
                                    {error}
                                </div>
                            )}
                            <FieldInput
                                label="Username / Email"
                                placeholder="admin@kima.co.id"
                                value={form.identifier}
                                onChange={(val) => setForm(f => ({ ...f, identifier: val }))}
                            />
                            <div className="space-y-1">
                                <FieldInput
                                    label="Password"
                                    type="password"
                                    placeholder="••••••••"
                                    value={form.password}
                                    onChange={(val) => setForm(f => ({ ...f, password: val }))}
                                />
                                <div className="flex justify-end pt-3"> {/* Jarak Lupa Pass ditambah */}
                                    <button
                                        type="button"
                                        onClick={() => setActivePanel("forgot")}
                                        className="text-[10px] font-bold text-primary hover:text-primary/80 transition-all uppercase tracking-tighter"
                                    >
                                        Lupa Password?
                                    </button>
                                </div>
                            </div>
                            <button
                                type="submit"
                                className="w-full bg-slate-900 hover:bg-slate-800 text-white font-bold py-4 rounded-2xl shadow-xl transition-all active:scale-[0.98] text-sm"
                            >
                                Masuk ke Sistem
                            </button>
                        </form>

                        {/* Social Connect (6 Icons - Connect Kiri - Icons Rata Kanan) */}
                        <div className="mt-16 flex items-center justify-between gap-4">
                            <span className="text-[10px] font-black text-slate-400 uppercase tracking-[0.2em] shrink-0">Connect</span>
                            <div className="h-[1px] flex-grow bg-slate-100" />
                            <div className="flex items-center gap-4 shrink-0">
                                {/* Instagram */}
                                <a href="#" className="text-slate-300 hover:text-slate-900 transition-all transform hover:scale-110">
                                    <svg className="w-4 h-4 fill-current" viewBox="0 0 24 24"><path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/></svg>
                                </a>
                                {/* Facebook */}
                                <a href="#" className="text-slate-300 hover:text-slate-900 transition-all transform hover:scale-110">
                                    <svg className="w-4 h-4 fill-current" viewBox="0 0 24 24"><path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/></svg>
                                </a>
                                {/* Twitter / X */}
                                <a href="#" className="text-slate-300 hover:text-slate-900 transition-all transform hover:scale-110">
                                    <svg className="w-4 h-4 fill-current" viewBox="0 0 24 24"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>
                                </a>
                                {/* LinkedIn */}
                                <a href="#" className="text-slate-300 hover:text-slate-900 transition-all transform hover:scale-110">
                                    <svg className="w-4 h-4 fill-current" viewBox="0 0 24 24"><path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452z"/></svg>
                                </a>
                                {/* YouTube */}
                                <a href="#" className="text-slate-300 hover:text-slate-900 transition-all transform hover:scale-110">
                                    <svg className="w-4 h-4 fill-current" viewBox="0 0 24 24"><path d="M19.615 3.184c-3.604-.246-11.631-.245-15.23 0-3.897.266-4.356 2.62-4.385 8.816.029 6.185.484 8.549 4.385 8.816 3.6.245 11.626.246 15.23 0 3.897-.266 4.356-2.612 4.385-8.816-.029-6.185-.484-8.549-4.385-8.816zm-10.615 12.816v-8l8 3.993-8 4.007z"/></svg>
                                </a>
                            </div>
                        </div>
                    </div>

                    {/* --- BRANDING PANEL (SLIDING) --- */}
                    <div 
                        className={`absolute top-0 left-0 h-full w-full md:w-1/2 bg-slate-900 z-20 transition-transform duration-700 cubic-bezier(0.4, 0, 0.2, 1) flex flex-col justify-between p-12 overflow-hidden ${
                            activePanel === "login" ? "translate-x-0" : "translate-x-full"
                        }`}
                    >
                        <div className="absolute top-0 right-0 w-40 h-40 bg-yellow-400/5 rounded-full -mr-20 -mt-20 blur-3xl" />
                        
                        <div className="relative z-10">
                            <img
                                alt="Logo PT KIMA"
                                className="h-16 w-auto brightness-0 invert"
                                src="/logo-kima.png"
                            />
                            <div className="mt-20">
                                <h2 className="text-3xl font-light text-white leading-tight">
                                    Selamat Datang di <br />
                                    <span className="font-bold text-yellow-400">Digital Archive</span>
                                </h2>
                                <div className="h-[2px] w-12 bg-yellow-400 mt-6" />
                                <p className="text-slate-400 mt-8 text-sm leading-relaxed max-w-[280px]">
                                    Sistem manajemen arsip terintegrasi untuk efisiensi dan keamanan data PT Kawasan Industri Makassar.
                                </p>
                            </div>
                        </div>

                        <div className="relative z-10">
                            <p className="text-[10px] text-slate-500 font-medium tracking-wide">
                                © 2026 PT Kawasan Industri Makassar.
                            </p>
                        </div>
                    </div>

                </div>

                <div className="mt-8 text-center">
                    <p className="text-white/20 text-[9px] font-black uppercase tracking-[0.5em]">
                        Powered by IT Support KIMA
                    </p>
                </div>
            </div>

            <style dangerouslySetInnerHTML={{ __html: `
                @keyframes shake {
                    0%, 100% { transform: translateX(0); }
                    25% { transform: translateX(-4px); }
                    75% { transform: translateX(4px); }
                }
                .animate-shake {
                    animation: shake 0.2s ease-in-out 2;
                }
            `}} />
        </div>
    );
}