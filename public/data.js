// DATA FIKTIF untuk mockup. Di produksi: diganti baca dari "Sheet publik" (tersensor).
window.DATA = {
  lembaga: "Lembaga Contoh Peduli",
  periode: "1 Jan – 27 Okt 2026",
  tarifOperasional: 0.10, // pengaturan per lembaga; cek aturan PUB sebelum diubah
  saldoAwal: { tanpa: 1500000, dengan: 0 },
  saldoBankDilaporkan: 6982859, // hasil mutasi bank manual (rekonsiliasi)
  program: [
    { id: "P1", nama: "Beasiswa Anak Desa" },
    { id: "P2", nama: "Sembako Lansia" },
    { id: "P3", nama: "Air Bersih" }
  ],
  donasi: [ // donatur hanya inisial; kode unik sudah terpasang di nominal
    { tgl: "2026-08-03", ini: "R.H.", prog: "P1", jumlah: 500037 },
    { tgl: "2026-08-11", ini: "A.S.", prog: "P2", jumlah: 250112 },
    { tgl: "2026-08-19", ini: "Anonim", prog: "P3", jumlah: 1000450 },
    { tgl: "2026-09-02", ini: "D.P.", prog: "P1", jumlah: 300218 },
    { tgl: "2026-09-09", ini: "M.K.", prog: "P2", jumlah: 150071 },
    { tgl: "2026-09-15", ini: "Anonim", prog: "P1", jumlah: 2000333 },
    { tgl: "2026-09-21", ini: "S.W.", prog: "P3", jumlah: 750520 },
    { tgl: "2026-10-01", ini: "T.N.", prog: "P2", jumlah: 400091 },
    { tgl: "2026-10-08", ini: "B.A.", prog: "P1", jumlah: 100244 },
    { tgl: "2026-10-14", ini: "L.F.", prog: "P3", jumlah: 5000605 },
    { tgl: "2026-10-20", ini: "Anonim", prog: "P2", jumlah: 600178 }
  ],
  penyaluran: [
    { tgl: "2026-09-05", prog: "P1", mitra: "SDN Harapan 2", jumlah: 400000, bukti: "bukti/2026-09-05-sdn-harapan.jpg" },
    { tgl: "2026-09-25", prog: "P2", mitra: "Posyandu Lansia Melati", jumlah: 300000, bukti: "bukti/2026-09-25-melati.jpg" },
    { tgl: "2026-10-10", prog: "P1", mitra: "Yayasan Buku Nusantara", jumlah: 1500000, bukti: "bukti/2026-10-10-buku.pdf" },
    { tgl: "2026-10-18", prog: "P3", mitra: "Kelompok Tani Tirta", jumlah: 3000000, bukti: "bukti/2026-10-18-tirta.jpg" }
  ],
  beban: [ // beban operasional dibayar dari kas tanpa pembatasan
    { tgl: "2026-09-30", ket: "Domain & hosting", jumlah: 250000 },
    { tgl: "2026-10-15", ket: "Biaya transfer & administrasi", jumlah: 120000 }
  ]
};
