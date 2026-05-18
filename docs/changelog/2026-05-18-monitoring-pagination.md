# Changelog: Pagination pada Tabel Monitoring

**Tanggal:** 2026-05-18  
**Fitur:** Pagination pada Filter Tabel Monitoring  
**File:** `frontend/src/features/monitoring/MonitoringSpreadsheetPage.jsx`

---

## Ringkasan Perubahan

Menambahkan sistem pagination pada tabel monitoring billing untuk meningkatkan performa dan user experience saat menampilkan data pelanggan dalam jumlah besar.

---

## Detail Perubahan

### 1. **State Management Pagination**

Menambahkan state baru:
```javascript
const [currentPage, setCurrentPage] = useState(1);
const [itemsPerPage, setItemsPerPage] = useState(50);
```

### 2. **Auto-Reset Pagination**

Pagination otomatis reset ke halaman 1 ketika filter berubah:
```javascript
useEffect(() => {
    setCurrentPage(1);
}, [filters.search, filters.contractStatus, filters.routeStatus, filters.todoStatus, filters.package]);
```

### 3. **Pagination Calculations**

Menambahkan computed values:
- `totalPages`: Total halaman berdasarkan jumlah data dan items per page
- `startIndex`: Index awal data untuk halaman aktif
- `endIndex`: Index akhir data untuk halaman aktif
- `paginatedRows`: Data yang sudah di-slice sesuai halaman aktif

### 4. **Komponen PaginationControls**

Komponen UI pagination dengan fitur:
- **Info Display**: "Menampilkan X-Y dari Z lokasi"
- **Items Per Page Selector**: Dropdown untuk memilih 25, 50, 100, atau 200 items per halaman
- **Page Navigation**: 
  - Tombol Previous/Next
  - Nomor halaman dengan ellipsis untuk banyak halaman
  - Highlight halaman aktif dengan gold accent
- **Smart Page Numbers**: Menampilkan halaman dengan algoritma ellipsis untuk UX yang baik

### 5. **Penempatan Pagination**

Pagination ditempatkan di 2 lokasi:
- **Atas tabel**: Sebelum tabel dimulai (untuk navigasi cepat)
- **Bawah tabel**: Setelah data tabel (untuk navigasi setelah scroll)

### 6. **Scroll Behavior**

Ketika berpindah halaman, tabel otomatis scroll ke atas untuk UX yang lebih baik:
```javascript
const tableEl = document.getElementById("monitoring-table");
if (tableEl) {
    tableEl.scrollIntoView({ behavior: "smooth", block: "start" });
}
```

### 7. **Nomor Baris Konsisten**

Nomor baris di kolom "NO" tetap konsisten dengan posisi global data, bukan reset per halaman:
```javascript
const actualRowNumber = startIndex + rowIndex + 1;
```

---

## Manfaat

1. **Performa**: Hanya render data yang ditampilkan di halaman aktif
2. **UX**: Navigasi data besar menjadi lebih mudah dan terstruktur
3. **Fleksibilitas**: User bisa memilih jumlah items per halaman sesuai kebutuhan
4. **Konsistensi**: Pagination reset otomatis saat filter berubah

---

## Cara Penggunaan

1. **Navigasi Halaman**: Klik nomor halaman atau tombol Previous/Next
2. **Ubah Items Per Page**: Pilih dari dropdown (25, 50, 100, 200)
3. **Filter Data**: Pagination otomatis reset ke halaman 1 saat filter berubah
4. **Scroll Otomatis**: Saat pindah halaman, tabel otomatis scroll ke atas

---

## Testing Checklist

- [x] Pagination berfungsi dengan benar
- [x] Reset pagination saat filter berubah
- [x] Items per page selector berfungsi
- [x] Nomor baris konsisten dengan posisi global
- [x] Scroll behavior smooth saat pindah halaman
- [x] Ellipsis page numbers untuk banyak halaman
- [x] Styling konsisten dengan design system
- [x] Responsive di berbagai ukuran layar

---

## Catatan Teknis

- Pagination hanya ditampilkan jika `filteredRows.length > 0`
- Pagination tidak ditampilkan di mode `tableOnly`
- Default items per page: 50
- Algoritma ellipsis: Menampilkan max 7 page numbers visible
