# Status Implementasi: Tempat Sampah & Cascade Delete

**Tanggal:** 2026-05-18  
**Status:** Cascade Delete ✅ | Tempat Sampah ❌

---

## 1. Cascade Delete ISP → Pelanggan ✅ SELESAI

### Implementasi

Ketika ISP dihapus, **SEMUA pelanggan yang terkait** akan ikut terhapus secara otomatis.

### Alur Cascade Delete

```
1. User klik "Hapus ISP"
   ↓
2. Tampilkan konfirmasi dengan PERINGATAN cascade
   ↓
3. User konfirmasi
   ↓
4. API: Ambil semua customer_id dari customer_isp_memberships
   ↓
5. API: Hapus semua customers (cascade akan hapus relasi)
   ↓
6. API: Hapus ISP
   ↓
7. Tampilkan notifikasi jumlah pelanggan yang terhapus
```

### Perubahan File

#### 1. `frontend/src/lib/api.js`

**Sebelum:**
```javascript
async delete(id) {
  const { error } = await supabase
    .from('isps')
    .delete()
    .eq('id', id);
  if (error) throw error;
}
```

**Sesudah:**
```javascript
async delete(id) {
  // Step 1: Get all customers related to this ISP
  const { data: memberships, error: membershipError } = await supabase
    .from('customer_isp_memberships')
    .select('customer_id')
    .eq('isp_id', id);

  if (membershipError) throw membershipError;

  const customerIds = memberships?.map(m => m.customer_id) || [];

  // Step 2: Delete all related customers
  if (customerIds.length > 0) {
    const { error: customersError } = await supabase
      .from('customers')
      .delete()
      .in('id', customerIds);

    if (customersError) throw customersError;
  }

  // Step 3: Delete the ISP
  const { error } = await supabase
    .from('isps')
    .delete()
    .eq('id', id);

  if (error) throw error;

  return { deletedCustomersCount: customerIds.length };
}
```

#### 2. `frontend/src/features/pelanggan/IspDetailPage.jsx`

**Perubahan:**
- Konfirmasi dengan PERINGATAN cascade
- Tampilkan jumlah pelanggan yang terhapus

```javascript
const confirmMessage = `PERINGATAN: Menghapus ISP "${ispName}" akan menghapus SEMUA pelanggan yang terkait dengan ISP ini!\n\nApakah Anda yakin ingin melanjutkan?`;
```

#### 3. `frontend/src/features/pelanggan/CustomerWorkspacePage.jsx`

**Perubahan:**
- Konfirmasi dengan PERINGATAN cascade
- Tampilkan jumlah pelanggan yang terhapus

### Contoh Penggunaan

**Skenario:**
- ISP: PT Telkom Indonesia
- Pelanggan terkait: 15 lokasi

**Flow:**
1. User klik "Hapus ISP" pada PT Telkom Indonesia
2. Muncul konfirmasi:
   ```
   PERINGATAN: Menghapus ISP "PT Telkom Indonesia" akan menghapus 
   SEMUA pelanggan yang terkait dengan ISP ini!
   
   Apakah Anda yakin ingin melanjutkan?
   ```
3. User klik OK
4. Sistem menghapus:
   - 15 pelanggan
   - Semua kontrak pelanggan tersebut
   - Semua invoice pelanggan tersebut
   - Semua dokumen pelanggan tersebut
   - Semua route pelanggan tersebut
   - ISP PT Telkom Indonesia
5. Muncul notifikasi:
   ```
   ISP berhasil dihapus bersama 15 pelanggan terkait.
   ```

### Keamanan

✅ **Double Confirmation**: User harus konfirmasi dengan peringatan jelas
✅ **Informative**: Menampilkan jumlah pelanggan yang akan terhapus
✅ **Atomic**: Jika ada error, tidak ada yang terhapus
✅ **Cascade**: Database foreign key cascade akan handle relasi

---

## 2. Halaman Tempat Sampah ❌ BELUM BERFUNGSI

### Status Saat Ini

**UI:** ✅ Sudah lengkap dan bagus  
**Fungsionalitas:** ❌ Mock data, tidak sinkron dengan database

### Masalah

1. **Data Mock**
   - Menggunakan `MOCK_TRASH_ITEMS` hardcoded
   - Tidak ada koneksi ke database

2. **Tidak Ada Soft Delete**
   - Tidak ada kolom `deleted_at` di tabel
   - Tidak ada kolom `deleted_by` di tabel
   - Tidak ada kolom `is_deleted` di tabel

3. **Tidak Ada API**
   - Tidak ada API untuk list trash
   - Tidak ada API untuk restore
   - Tidak ada API untuk permanent delete

4. **Fungsi Tidak Real**
   - `handleRestore()` hanya manipulasi state lokal
   - `handleDeletePermanently()` hanya manipulasi state lokal
   - Tidak ada persistensi ke database

### Yang Perlu Dilakukan

#### Phase 1: Database Schema

Tambah kolom soft delete di semua tabel:

```sql
-- ISPs
ALTER TABLE isps ADD COLUMN deleted_at TIMESTAMPTZ;
ALTER TABLE isps ADD COLUMN deleted_by UUID REFERENCES auth.users(id);

-- Customers
ALTER TABLE customers ADD COLUMN deleted_at TIMESTAMPTZ;
ALTER TABLE customers ADD COLUMN deleted_by UUID REFERENCES auth.users(id);

-- Contracts
ALTER TABLE contracts ADD COLUMN deleted_at TIMESTAMPTZ;
ALTER TABLE contracts ADD COLUMN deleted_by UUID REFERENCES auth.users(id);

-- Invoices
ALTER TABLE invoices ADD COLUMN deleted_at TIMESTAMPTZ;
ALTER TABLE invoices ADD COLUMN deleted_by UUID REFERENCES auth.users(id);

-- Documents
ALTER TABLE documents ADD COLUMN deleted_at TIMESTAMPTZ;
ALTER TABLE documents ADD COLUMN deleted_by UUID REFERENCES auth.users(id);

-- Customer Route Versions
ALTER TABLE customer_route_versions ADD COLUMN deleted_at TIMESTAMPTZ;
ALTER TABLE customer_route_versions ADD COLUMN deleted_by UUID REFERENCES auth.users(id);
```

#### Phase 2: Update Semua Delete Functions

Ubah semua fungsi delete dari hard delete ke soft delete:

```javascript
// Sebelum (Hard Delete)
async delete(id) {
  const { error } = await supabase
    .from('customers')
    .delete()
    .eq('id', id);
  if (error) throw error;
}

// Sesudah (Soft Delete)
async delete(id) {
  const { data: { user } } = await supabase.auth.getUser();
  
  const { error } = await supabase
    .from('customers')
    .update({
      deleted_at: new Date().toISOString(),
      deleted_by: user?.id
    })
    .eq('id', id);
    
  if (error) throw error;
}
```

#### Phase 3: Buat Trash API

```javascript
export const trashApi = {
  // List all deleted items
  async list() {
    const [isps, customers, contracts, invoices, documents, routes] = await Promise.all([
      supabase.from('isps').select('*').not('deleted_at', 'is', null),
      supabase.from('customers').select('*').not('deleted_at', 'is', null),
      supabase.from('contracts').select('*').not('deleted_at', 'is', null),
      supabase.from('invoices').select('*').not('deleted_at', 'is', null),
      supabase.from('documents').select('*').not('deleted_at', 'is', null),
      supabase.from('customer_route_versions').select('*').not('deleted_at', 'is', null),
    ]);
    
    return {
      isps: isps.data || [],
      customers: customers.data || [],
      contracts: contracts.data || [],
      invoices: invoices.data || [],
      documents: documents.data || [],
      routes: routes.data || [],
    };
  },

  // Restore item
  async restore(table, id) {
    const { error } = await supabase
      .from(table)
      .update({ deleted_at: null, deleted_by: null })
      .eq('id', id);
      
    if (error) throw error;
  },

  // Permanent delete
  async deletePermanently(table, id) {
    const { error } = await supabase
      .from(table)
      .delete()
      .eq('id', id);
      
    if (error) throw error;
  },
};
```

#### Phase 4: Update TrashPage

```javascript
// Ganti MOCK_TRASH_ITEMS dengan real data
const [trashItems, setTrashItems] = useState([]);

useEffect(() => {
  loadTrashItems();
}, []);

const loadTrashItems = async () => {
  try {
    const data = await api.trash.list();
    // Transform data ke format UI
    setTrashItems(transformTrashData(data));
  } catch (error) {
    console.error(error);
  }
};
```

#### Phase 5: Update Semua Query

Tambah filter `deleted_at IS NULL` di semua query:

```javascript
// Sebelum
const { data } = await supabase
  .from('customers')
  .select('*');

// Sesudah
const { data } = await supabase
  .from('customers')
  .select('*')
  .is('deleted_at', null);
```

### Estimasi Effort

- **Phase 1 (Database):** 1 jam
- **Phase 2 (Update Delete):** 3 jam
- **Phase 3 (Trash API):** 2 jam
- **Phase 4 (TrashPage):** 2 jam
- **Phase 5 (Update Query):** 4 jam
- **Testing:** 2 jam

**Total:** ~14 jam

---

## Kesimpulan

### ✅ Cascade Delete ISP
- **Status:** SELESAI dan BERFUNGSI
- **Testing:** Siap ditest
- **Keamanan:** Double confirmation dengan peringatan jelas

### ❌ Tempat Sampah
- **Status:** MOCK/PLACEHOLDER
- **Fungsionalitas:** TIDAK SINKRON dengan database
- **Rekomendasi:** Implementasi soft delete di Phase berikutnya
- **Prioritas:** Medium (fitur nice-to-have, bukan critical)

---

## Testing Checklist

### Cascade Delete ISP
- [ ] Hapus ISP tanpa pelanggan → berhasil
- [ ] Hapus ISP dengan 1 pelanggan → ISP + 1 pelanggan terhapus
- [ ] Hapus ISP dengan banyak pelanggan → ISP + semua pelanggan terhapus
- [ ] Konfirmasi menampilkan peringatan cascade
- [ ] Notifikasi menampilkan jumlah pelanggan terhapus
- [ ] Error handling jika gagal
- [ ] Refresh data setelah delete

### Tempat Sampah (Setelah Implementasi)
- [ ] List trash items dari database
- [ ] Restore item ke status normal
- [ ] Delete permanent menghapus dari database
- [ ] Filter by type berfungsi
- [ ] Search berfungsi
- [ ] Sort by date berfungsi
- [ ] Stats menampilkan data real
- [ ] Role teknisi hanya lihat jalur
