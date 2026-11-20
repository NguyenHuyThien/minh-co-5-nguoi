package vn.edu.vhu.ltdd.marketadmin;

public class SapHang {
    public String maSap;
    public String khuVuc;
    public String tenGianHang;
    public String maTT;
    public String tenTieuThuong;
    public String soDienThoai;
    public String ngayDangKy;
    public int trangThai;
    public String lyDo;

    public SapHang(String maSap, String khuVuc, String tenGianHang, String maTT, String tenTieuThuong, String soDienThoai, String ngayDangKy, int trangThai, String lyDo) {
        this.maSap = maSap;
        this.khuVuc = khuVuc;
        this.tenGianHang = tenGianHang;
        this.maTT = maTT;
        this.tenTieuThuong = tenTieuThuong;
        this.soDienThoai = soDienThoai;
        this.ngayDangKy = ngayDangKy;
        this.trangThai = trangThai;
        this.lyDo = lyDo;
    }
}