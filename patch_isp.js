const fs = require('fs');
const appPath = 'frontend/src/App.jsx';
let code = fs.readFileSync(appPath, 'utf8');

const targetFunctionStart = code.indexOf('function IspDetailPage');
const nextFunctionStart = code.indexOf('\nfunction TenantDetailPage', targetFunctionStart);

if (targetFunctionStart === -1 || nextFunctionStart === -1) {
    console.log('Error: Function not found.');
    process.exit(1);
}

const replacement = `
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
            const result = await fetchJson(\`\${API_BASE_URL}/api/isps/\${isp.id}\`);
            setDetail(result ?? null);
            setTimeline([
                { id: \`t1-\${isp.id}\`, date: new Date().toISOString(), type: "todo", title: "Pembuatan ISP", description: "ISP dibuat di sistem." }
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
                                className={\`flex items-center gap-2 whitespace-nowrap border-b-2 px-1 py-4 text-sm font-semibold transition-colors \${activeTab === tab.id ? "border-primary text-primary" : "border-transparent text-slate-500 hover:border-slate-300 hover:text-slate-700"}\`}
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
                                    <p className="mt-1 text-base font-bold text-slate-800">{(detail?.activationFeeAmount || isp.activationFeeAmount) ? \`Rp \${(detail?.activationFeeAmount || isp.activationFeeAmount).toLocaleString('id-ID')} (Menunggu)\` : "Selesai"}</p>
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
`;

const newCode = code.slice(0, targetFunctionStart) + replacement + code.slice(nextFunctionStart);
fs.writeFileSync(appPath, newCode);
console.log('Successfully patched IspDetailPage.');
