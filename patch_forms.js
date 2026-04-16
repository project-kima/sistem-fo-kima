const fs = require('fs');
const appPath = 'frontend/src/App.jsx';
let code = fs.readFileSync(appPath, 'utf8');

// ========================================================================
// 1. FIX ISP FORM: Replace paket input section
// Remove: Pembagian Tagihan, Periode Tagihan, custom billing, Biaya Aktivasi
// Change: Paket select + conditional input (Core = number, Shared = ratio)
// ========================================================================

const oldIspFormFields = `<FieldSelect label="Paket" value={form.paket} onChange={(value) => setForm((previous) => ({ ...previous, paket: value }))} options={[{ value: "core", label: "Core" }, { value: "shared", label: "Shared Core" }]} />
                        <FieldInput label="Pembagian Tagihan" type="number" value={form.jumlah} onChange={(value) => setForm((previous) => ({ ...previous, jumlah: value }))} />
                        <FieldSelect label="Periode Tagihan" value={form.billingPeriodMode} onChange={(value) => setForm((previous) => ({ ...previous, billingPeriodMode: value }))} options={[{ value: "bulanan", label: "Bulanan" }, { value: "3bulanan", label: "3 Bulan" }, { value: "custom", label: "Custom" }]} />
                        {form.billingPeriodMode === "custom" && (
                            <div className="flex gap-2">
                                <FieldInput label="Setiap" type="number" value={form.billingCustomEvery} onChange={(value) => setForm((previous) => ({ ...previous, billingCustomEvery: value }))} />
                                <FieldSelect label="Unit" value={form.billingCustomUnit} onChange={(value) => setForm((previous) => ({ ...previous, billingCustomUnit: value }))} options={[{ value: "hari", label: "Hari" }, { value: "bulan", label: "Bulan" }, { value: "tahun", label: "Tahun" }]} />
                            </div>
                        )}
                        <FieldInput label="Biaya Aktivasi" type="number" value={form.activationFeeAmount} onChange={(value) => setForm((previous) => ({ ...previous, activationFeeAmount: value }))} />`;

const newIspFormFields = `<FieldSelect label="Paket" value={form.paket} onChange={(value) => setForm((previous) => ({ ...previous, paket: value }))} options={[{ value: "core", label: "Core" }, { value: "shared", label: "Shared Core" }]} />
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
                        )}`;

if (code.includes(oldIspFormFields)) {
    code = code.replace(oldIspFormFields, newIspFormFields);
    console.log('✅ ISP form fields replaced');
} else {
    console.log('❌ ISP form fields NOT found - skipping');
}

// Add ratioLeft/ratioRight to ISP form state
const oldIspState = `jumlah: "0",
        billingPeriodMode: "bulanan",
        billingCustomEvery: "",
        billingCustomUnit: "bulan",
        activationFeeAmount: "0",
    });
    const [submitError, setSubmitError] = useState("");
    const [isSubmitting, setIsSubmitting] = useState(false);

    const handleSubmit = async (event) => {
        event.preventDefault();
        if (!form.name.trim() || !form.contractReference.trim()) {
            setSubmitError("Nama ISP dan nomor kontrak induk wajib diisi.");`;

const newIspState = `jumlah: "0",
        ratioLeft: "1",
        ratioRight: "8",
    });
    const [submitError, setSubmitError] = useState("");
    const [isSubmitting, setIsSubmitting] = useState(false);

    const handleSubmit = async (event) => {
        event.preventDefault();
        if (!form.name.trim() || !form.contractReference.trim()) {
            setSubmitError("Nama ISP dan nomor kontrak induk wajib diisi.");`;

if (code.includes(oldIspState)) {
    code = code.replace(oldIspState, newIspState);
    console.log('✅ ISP form state replaced');
} else {
    console.log('❌ ISP form state NOT found');
}

// Fix ISP form submit payload - remove billing/activation, fix jumlah for shared
const oldIspPayload = `paket: form.paket,
                    jumlah: Math.round(Number(form.jumlah || 0)),
                    billingPeriodMode: form.billingPeriodMode,
                    billingCustomEvery: form.billingPeriodMode === "custom" ? Number(form.billingCustomEvery) : undefined,
                    billingCustomUnit: form.billingPeriodMode === "custom" ? form.billingCustomUnit : undefined,
                    activationFeeAmount: Math.round(Number(form.activationFeeAmount || 0)),`;

const newIspPayload = `paket: form.paket,
                    jumlah: form.paket === "core" ? Math.round(Number(form.jumlah || 0)) : 0,
                    sharingRatio: form.paket === "shared" ? \`\${form.ratioLeft || 1}:\${form.ratioRight || 8}\` : undefined,`;

if (code.includes(oldIspPayload)) {
    code = code.replace(oldIspPayload, newIspPayload);
    console.log('✅ ISP payload replaced');
} else {
    console.log('❌ ISP payload NOT found');
}

// ========================================================================
// 2. FIX TENANT FORM: Replace single ratio input with two-field ratio
// ========================================================================
const oldTenantRatio = `<FieldInput label="Shared Core Ratio" value={form.ratio} onChange={(value) => setForm((previous) => ({ ...previous, ratio: value }))} placeholder="1:8" />`;

const newTenantRatio = `<div>
                                <label className="mb-2 block text-[10px] font-bold uppercase tracking-widest text-on-surface-variant">Rasio Shared Core</label>
                                <div className="flex items-center gap-2">
                                    <input className="w-24 rounded-lg border border-slate-200 bg-surface-container-lowest px-3 py-2.5 text-sm focus:border-primary focus:ring-2 focus:ring-primary/10" type="number" min="1" value={form.ratioLeft} onChange={(e) => setForm((prev) => ({ ...prev, ratioLeft: e.target.value }))} placeholder="1" />
                                    <span className="text-lg font-bold text-slate-400">:</span>
                                    <input className="w-24 rounded-lg border border-slate-200 bg-surface-container-lowest px-3 py-2.5 text-sm focus:border-primary focus:ring-2 focus:ring-primary/10" type="number" min="1" value={form.ratioRight} onChange={(e) => setForm((prev) => ({ ...prev, ratioRight: e.target.value }))} placeholder="8" />
                                </div>
                            </div>`;

if (code.includes(oldTenantRatio)) {
    code = code.replace(oldTenantRatio, newTenantRatio);
    console.log('✅ Tenant ratio input replaced');
} else {
    console.log('❌ Tenant ratio input NOT found');
}

// Update tenant form state to use ratioLeft/ratioRight
const oldTenantState = `ratio: "1:8",`;
const newTenantState = `ratioLeft: "1",
        ratioRight: "8",`;

if (code.includes(oldTenantState)) {
    code = code.replace(oldTenantState, newTenantState);
    console.log('✅ Tenant state replaced');
} else {
    console.log('❌ Tenant state NOT found');
}

// Update tenant validation
const oldTenantValidation = `if (!/^[1-9]\\d*:[1-9]\\d*$/.test(form.ratio.trim())) {
            setSubmitError("Shared Core ratio harus memakai format seperti 1:8.");
            return;
        }`;

const newTenantValidation = `if (!form.ratioLeft || !form.ratioRight || Number(form.ratioLeft) < 1 || Number(form.ratioRight) < 1) {
            setSubmitError("Shared Core ratio tidak valid. Masukkan angka >= 1 di kedua kolom.");
            return;
        }`;

if (code.includes(oldTenantValidation)) {
    code = code.replace(oldTenantValidation, newTenantValidation);
    console.log('✅ Tenant validation replaced');
} else {
    console.log('❌ Tenant validation NOT found');
}

// Update tenant payload
const oldTenantPayload = `contractSharingRatio: form.ratio.trim(),`;
const newTenantPayload = `contractSharingRatio: \`\${form.ratioLeft || 1}:\${form.ratioRight || 8}\`,`;

if (code.includes(oldTenantPayload)) {
    code = code.replace(oldTenantPayload, newTenantPayload);
    console.log('✅ Tenant payload replaced');
} else {
    console.log('❌ Tenant payload NOT found');
}

// ========================================================================
// 3. FIX TENANT DETAIL OVERVIEW: Add kelengkapan berkas, biaya aktivasi,
//    dokumen terbaru, aktivitas terbaru
// ========================================================================

const oldTenantOverview = `{activeTab === "overview" && (
                    <div className="space-y-8">
                        <section className="grid grid-cols-1 gap-4 md:grid-cols-2 xl:grid-cols-4">
                            <SummaryCard label="ISP Terkait" value={isps.length} icon="device_hub" />
                            <SummaryCard label="Invoice" value={invoices.length} icon="receipt_long" />
                            <SummaryCard label="Priority To Do" value={todoSummary.counts?.priority ?? 0} icon="priority_high" />
                            <SummaryCard label="Need Action" value={todoSummary.counts?.needAction ?? 0} icon="pending_actions" />
                        </section>
                        <section className="grid grid-cols-1 gap-6 xl:grid-cols-2">
                            <div className="rounded-2xl bg-surface-container-lowest p-6 shadow-sm">
                                <h2 className="mb-4 text-lg font-bold text-blue-950">Kontrak</h2>
                                <div className="overflow-x-auto">
                                    <table className="w-full border-collapse">
                                        <thead>
                                            <tr className="border-b border-slate-100">
                                                <th className="px-3 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Nomor kontrak</th>
                                                <th className="px-3 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Periode</th>
                                                <th className="px-3 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">Status</th>
                                                <th className="px-3 py-3 text-left text-[11px] font-black uppercase tracking-wider text-slate-500">BAK upload</th>
                                            </tr>
                                        </thead>
                                        <tbody><tr><td className="px-3 py-4 text-sm font-semibold text-slate-800">{contract?.contractNumber ?? "-"}</td><td className="px-3 py-4 text-sm text-slate-600">{formatContractPeriod(contract?.startDate, contract?.endDate)}</td><td className="px-3 py-4 text-sm text-slate-600">{contract?.status ?? "-"}</td><td className="px-3 py-4 text-sm text-slate-600">{versions[0]?.bakDocumentId ? \`#\${versions[0].bakDocumentId}\` : "Belum ada BAK"}</td></tr></tbody>
                                    </table>
                                </div>
                            </div>
                            <div className="rounded-2xl bg-surface-container-lowest p-6 shadow-sm">
                                <h2 className="mb-4 text-lg font-bold text-blue-950">To Do Otomatis</h2>
                                <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
                                    <TodoColumn title="Priority" items={todoSummary.priority ?? []} />
                                    <TodoColumn title="Need Action" items={todoSummary.needAction ?? []} />
                                    <TodoColumn title="Info" items={todoSummary.info ?? []} />
                                </div>
                            </div>
                        </section>
                    </div>
                )}`;

const newTenantOverview = `{activeTab === "overview" && (
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
                                        <tbody><tr><td className="px-3 py-4 text-sm font-semibold text-slate-800">{contract?.contractNumber ?? "-"}</td><td className="px-3 py-4 text-sm text-slate-600">{formatContractPeriod(contract?.startDate, contract?.endDate)}</td><td className="px-3 py-4 text-sm text-slate-600">{contract?.status ?? "-"}</td><td className="px-3 py-4 text-sm text-slate-600">{versions[0]?.bakDocumentId ? \`#\${versions[0].bakDocumentId}\` : "Belum ada BAK"}</td></tr></tbody>
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
                                                <div className={\`flex h-9 w-9 shrink-0 items-center justify-center rounded-full \${timelineColorMap[event.type] ?? "text-slate-700 bg-slate-100"}\`}>
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
                )}`;

if (code.includes(oldTenantOverview)) {
    code = code.replace(oldTenantOverview, newTenantOverview);
    console.log('✅ Tenant overview replaced');
} else {
    console.log('❌ Tenant overview NOT found');
}

fs.writeFileSync(appPath, code);
console.log('\n🎉 All patches applied. File saved.');
