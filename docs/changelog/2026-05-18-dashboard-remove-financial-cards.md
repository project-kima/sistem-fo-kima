# Changelog: Penghapusan Card Finansial dari Dashboard

**Tanggal:** 2026-05-18  
**Fitur:** Simplifikasi Dashboard - Hapus Card Finansial  
**File:** `frontend/src/features/dashboard/DashboardPage.jsx`

---

## Ringkasan Perubahan

Menghapus 4 card finansial dari dashboard untuk menyederhanakan tampilan dan fokus pada metrik operasional.

---

## Card yang Dihapus

### 1. **Pendapatan Terealisasi** (KPI Section)
- Icon: `account_balance_wallet`
- Data: `formatCurrency(insights?.totals?.revenuePaid ?? 0)`
- Label: "Lunas Terverifikasi"

### 2. **Proyeksi Tagihan** (KPI Section)
- Icon: `analytics`
- Data: `formatCurrency(insights?.totals?.revenueProjected ?? 0)`
- Label: "Total Tagihan Berjalan"

### 3. **Kinerja Keuangan** (Chart Section)
- Tipe: ComposedChart (Bar + Line)
- Data: Realisasi vs Proyeksi per bulan
- Filter: Year selector dengan mode (this_year, range_years, specific_year, custom)

### 4. **Status Likuiditas** (Circular Progress)
- Tipe: Circular progress chart
- Data: Payment ratio (lunas/total)
- Detail: Unit Lunas, Unit Tertunda, Peringatan Terlambat

---

## Perubahan Teknis

### State yang Dihapus
```javascript
// Dihapus
const [financialFilter, setFinancialFilter] = useState({...});
```

### Computed Values yang Dihapus
```javascript
// Dihapus
const financialData = useMemo(() => {...}, [insights]);
const paymentRatio = useMemo(() => {...}, [billingSummary]);
```

### Komponen yang Dihapus
```javascript
// Dihapus
function StatusRow({ label, value, color, isAlert }) {...}
```

### Import yang Dihapus
```javascript
// Dihapus
import { monitoringMonths } from "../../app/constants";
import { formatCurrency } from "../../app/utils";
```

---

## Layout Setelah Perubahan

### KPI Section
**Sebelum:** 4 cards (2x2 grid pada desktop)
```
[Pendapatan] [Proyeksi] [Jaringan] [Lokasi]
```

**Sesudah:** 2 cards (1x2 grid)
```
[Jaringan] [Lokasi]
```

### Chart Section
**Sebelum:** 3 cards
```
[Kinerja Keuangan (2 col)] [Status Likuiditas (1 col)]
```

**Sesudah:** Dihapus seluruhnya, langsung ke Growth Chart

---

## Card yang Tetap Ada

1. **Core Infrastructure Section**
   - Capacity Core
   - Sewa Core
   - Sewa Sharing (tabel)
   - Trend Grafik Sharing

2. **Growth Chart**
   - Pertumbuhan Lokasi/ISP
   - Filter year selector

3. **Tindakan Kritis**
   - Alert list

4. **Mitra Utama**
   - Top 5 ISP

5. **Status Jalur**
   - Aktif, Gangguan, Perbaikan

6. **Status Kontrak**
   - Beroperasi, Belum Diperpanjang, Berhenti

---

## Manfaat

1. **Simplifikasi**: Dashboard lebih fokus pada metrik operasional
2. **Performa**: Mengurangi data fetching dan rendering
3. **Clarity**: Menghilangkan duplikasi informasi finansial
4. **Maintenance**: Mengurangi kompleksitas kode

---

## Testing Checklist

- [x] Dashboard load tanpa error
- [x] KPI section menampilkan 2 cards
- [x] Chart section tidak menampilkan Kinerja Keuangan
- [x] Circular progress Status Likuiditas tidak ada
- [x] Growth chart tetap berfungsi
- [x] Semua card lain tetap berfungsi normal
- [x] Tidak ada console error
- [x] Responsive di berbagai ukuran layar

---

## Catatan

Jika di masa depan diperlukan kembali metrik finansial, data masih tersedia di:
- `insights.totals.revenuePaid`
- `insights.totals.revenueProjected`
- `billingSummary.lunas/belum_bayar/terlambat`

API endpoint monitoring tetap mengembalikan data finansial lengkap.
