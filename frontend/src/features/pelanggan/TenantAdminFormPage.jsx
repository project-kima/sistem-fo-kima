

import { useEffect, useState } from "react";
import AppShell from "../../components/layout/AppShell";
import { FieldInput, FieldSelect } from "../../components/shared/AppShared";
import { API_BASE_URL, fetchJson } from "../../app/utils";

function TenantAdminFormPage({ initialData = null, isps = [], lockedIsp = null, mode = "create", onCancel, onNavigate, onSaved }) {
    const [form, setForm] = useState({
        name: "",
        status: "aktif",
        paket: "core",
        jumlah: "0",
        ratioLeft: "1",
        ratioRight: "8",
        contractStartDate: "",
        contractEndDate: "",
        billingPeriodMode: "bulanan",
        billingCustomEvery: "",
        billingCustomUnit: "bulan",
        activationFeeAmount: "0",
    });
    const [selectedIspId, setSelectedIspId] = useState(null);
    const [submitError, setSubmitError] = useState("");
    const [isSubmitting, setIsSubmitting] = useState(false);
    const isEditMode = mode === "edit";
    const isLockedToIsp = !isEditMode && Boolean(lockedIsp?.id);

    useEffect(() => {
        if (!initialData) {
            return;
        }

        setForm((previous) => ({
            ...previous,
            name: initialData.name ?? "",
            status: initialData.rawStatus ?? initialData.status ?? "aktif",
        }));
    }, [initialData]);

    useEffect(() => {
        if (!isLockedToIsp) {
            return;
        }

        setSelectedIspId(Number(lockedIsp.id));
    }, [isLockedToIsp, lockedIsp]);

    const selectIsp = (ispId) => {
        setSelectedIspId(ispId);
    };

    const handleSubmit = async (event) => {
        event.preventDefault();

        if (!form.name.trim()) {
            setSubmitError("Nama tenant wajib diisi.");
            return;
        }

        if (!isEditMode) {
            if (!selectedIspId) {
                setSubmitError("Tenant harus terhubung ke satu ISP.");
                return;
            }
            if (form.paket === "shared" && (!form.ratioLeft || !form.ratioRight || Number(form.ratioLeft) < 1 || Number(form.ratioRight) < 1)) {
                setSubmitError("Shared Core ratio tidak valid. Masukkan angka >= 1 di kedua kolom.");
                return;
            }
            if (!form.contractStartDate || !form.contractEndDate || form.contractStartDate > form.contractEndDate) {
                setSubmitError("Periode kontrak tenant tidak valid.");
                return;
            }
        }

        setIsSubmitting(true);
        setSubmitError("");

        try {
            const endpoint = isEditMode && initialData?.id
                ? `${API_BASE_URL}/api/customers/${initialData.id}`
                : `${API_BASE_URL}/api/customers`;
            const result = await fetchJson(endpoint, {
                method: isEditMode ? "PATCH" : "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(isEditMode
                    ? {
                        name: form.name.trim(),
                        status: form.status,
                    }
                    : {
                        name: form.name.trim(),
                        status: form.status,
                        ispIds: [selectedIspId],
                        contractStartDate: form.contractStartDate,
                        contractEndDate: form.contractEndDate,
                        paket: form.paket,
                        jumlah: form.paket === "core" ? Math.round(Number(form.jumlah || 0)) : 0,
                        contractSharingRatio: form.paket === "shared" ? `${form.ratioLeft || 1}:${form.ratioRight || 8}` : undefined,
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
            setSubmitError(requestError instanceof Error ? requestError.message : `Terjadi kesalahan saat ${isEditMode ? "memperbarui" : "menyimpan"} tenant.`);
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <AppShell activeSection="customers" onNavigate={onNavigate}>
            <form className="mx-auto max-w-6xl space-y-8" onSubmit={handleSubmit}>
                <div className="flex flex-col justify-between gap-4 md:flex-row md:items-end">
                    <div>
                        <p className="text-xs font-black uppercase tracking-widest text-on-surface-variant/60">{isEditMode ? "Edit Tenant" : "Tambah Tenant"}</p>
                        <h1 className="mt-2 text-3xl font-extrabold text-primary">{isEditMode ? "Edit Lokasi / Tenant" : "Tenant Baru"}</h1>
                        {!isEditMode && (
                            <p className="mt-2 max-w-xl text-sm text-on-surface-variant">
                                Sistem akan otomatis membuat kontrak, contract version awal, dan draft invoice.
                            </p>
                        )}
                        {isLockedToIsp && (
                            <p className="mt-2 max-w-xl text-sm text-on-surface-variant">
                                Tenant ini akan otomatis terhubung ke ISP: <span className="font-semibold text-on-surface">{lockedIsp.name}</span>.
                            </p>
                        )}
                    </div>
                    <div className="flex gap-3">
                        <button className="rounded-xl px-6 py-2.5 font-semibold text-on-surface-variant transition-all hover:bg-surface-container-high" onClick={onCancel} type="button">Batalkan</button>
                        <button className="rounded-xl bg-gradient-to-br from-primary to-primary-container px-8 py-2.5 font-bold text-white shadow-lg shadow-primary/20 transition-opacity hover:opacity-95 disabled:cursor-not-allowed disabled:opacity-60" disabled={isSubmitting} type="submit">{isSubmitting ? "Menyimpan..." : isEditMode ? "Simpan Perubahan" : "Simpan Tenant"}</button>
                    </div>
                </div>

                {submitError && <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm font-medium text-red-700">{submitError}</div>}

                <div className={`grid gap-8 ${isEditMode ? "grid-cols-1" : "grid-cols-12"}`}>
                    <section className="col-span-12 space-y-8 lg:col-span-8">
                        <div className="rounded-lg bg-surface-container-lowest p-8 shadow-sm">
                            <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
                                <FieldInput label="Nama Tenant" value={form.name} onChange={(value) => setForm((previous) => ({ ...previous, name: value }))} />
                                <FieldSelect label="Status" value={form.status} onChange={(value) => setForm((previous) => ({ ...previous, status: value }))} options={[{ value: "aktif", label: "Beroperasi" }, { value: "nonaktif", label: "Berhenti" }]} />
                                {!isEditMode && (
                                    <>
                                        <FieldSelect label="Paket" value={form.paket} onChange={(value) => setForm((previous) => ({ ...previous, paket: value }))} options={[{ value: "core", label: "Core" }, { value: "shared", label: "Shared Core" }]} />
                                        {form.paket === "core" ? (
                                            <FieldInput label="Jumlah Core" type="number" value={form.jumlah} onChange={(value) => setForm((previous) => ({ ...previous, jumlah: value }))} placeholder="Contoh: 4" />
                                        ) : (
                                            <div>
                                                <label className="mb-2 block text-[10px] font-bold uppercase tracking-widest text-on-surface-variant">Rasio Shared Core</label>
                                                <div className="flex items-center gap-2">
                                                    <input className="w-24 rounded-lg border border-slate-200 bg-surface-container-lowest px-3 py-2.5 text-sm focus:border-primary focus:ring-2 focus:ring-primary/10" type="number" min="1" value={form.ratioLeft} onChange={(event) => setForm((previous) => ({ ...previous, ratioLeft: event.target.value }))} placeholder="1" />
                                                    <span className="text-lg font-bold text-slate-400">:</span>
                                                    <input className="w-24 rounded-lg border border-slate-200 bg-surface-container-lowest px-3 py-2.5 text-sm focus:border-primary focus:ring-2 focus:ring-primary/10" type="number" min="1" value={form.ratioRight} onChange={(event) => setForm((previous) => ({ ...previous, ratioRight: event.target.value }))} placeholder="8" />
                                                </div>
                                            </div>
                                        )}
                                        <FieldInput label="Contract Start" type="date" value={form.contractStartDate} onChange={(value) => setForm((previous) => ({ ...previous, contractStartDate: value }))} />
                                        <FieldInput label="Contract End" type="date" value={form.contractEndDate} onChange={(value) => setForm((previous) => ({ ...previous, contractEndDate: value }))} />
                                    </>
                                )}
                            </div>
                        </div>

                        {!isEditMode && !isLockedToIsp && (
                            <div className="rounded-lg bg-surface-container-lowest p-8 shadow-sm">
                                <div className="mb-6 flex items-center justify-between gap-3">
                                    <h3 className="text-lg font-bold text-on-surface">Pilih ISP</h3>
                                    <p className="text-xs text-on-surface-variant">Gunakan tombol `Tambah ISP` jika ISP belum tersedia.</p>
                                </div>
                                <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
                                    {isps.map((isp) => (
                                        <label key={isp.id} className={`flex cursor-pointer items-start gap-3 rounded-xl border p-4 transition-colors ${selectedIspId === isp.id ? "border-primary bg-blue-50/60" : "border-slate-200 bg-white"}`}>
                                            <input checked={selectedIspId === isp.id} className="mt-1 flex-shrink-0" name="selectIspRadio" onChange={() => selectIsp(isp.id)} type="radio" />
                                            <div>
                                                <p className="text-sm font-semibold text-on-surface">{isp.name}</p>
                                                <p className="mt-1 text-xs text-on-surface-variant">{isp.contractReference || "Tanpa referensi kontrak"}</p>
                                            </div>
                                        </label>
                                    ))}
                                </div>
                            </div>
                        )}
                        {!isEditMode && isLockedToIsp && (
                            <div className="rounded-lg bg-surface-container-lowest p-8 shadow-sm">
                                <div className="mb-4 flex items-center justify-between gap-3">
                                    <h3 className="text-lg font-bold text-on-surface">ISP Tujuan</h3>
                                    <span className="rounded-full bg-emerald-100 px-3 py-1 text-xs font-bold text-emerald-700">Otomatis Terkunci</span>
                                </div>
                                <div className="rounded-xl border border-primary/20 bg-blue-50/60 p-4">
                                    <p className="text-sm font-semibold text-on-surface">{lockedIsp.name}</p>
                                    <p className="mt-1 text-xs text-on-surface-variant">{lockedIsp.contractReference || "Tanpa referensi kontrak"}</p>
                                </div>
                            </div>
                        )}
                    </section>

                    {!isEditMode && (
                        <section className="col-span-12 space-y-8 lg:col-span-4">
                            <div className="rounded-lg bg-surface-container-low p-6">
                                <div className="space-y-6">
                                    <div>
                                        <label className="mb-3 block text-[10px] font-bold uppercase tracking-widest text-on-surface-variant">Billing Period</label>
                                        <div className="grid grid-cols-3 gap-2">
                                            {["bulanan", "3bulanan", "custom"].map((modeValue) => (
                                                <button key={modeValue} className={`rounded-lg py-2 text-xs font-bold transition-colors ${form.billingPeriodMode === modeValue ? "bg-primary text-white" : "bg-surface-container-lowest text-on-surface-variant hover:bg-slate-200"}`} onClick={() => setForm((previous) => ({ ...previous, billingPeriodMode: modeValue }))} type="button">{modeValue === "bulanan" ? "Bulanan" : modeValue === "3bulanan" ? "3 Bulanan" : "Custom"}</button>
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
                    )}
                </div>
            </form>
        </AppShell>
    );
}

export default TenantAdminFormPage;
