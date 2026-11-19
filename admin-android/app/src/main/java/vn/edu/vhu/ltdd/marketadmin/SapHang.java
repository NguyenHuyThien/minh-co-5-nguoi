package vn.edu.vhu.ltdd.marketadmin;

public class SapHang {
    public String maSap;
    public String khuVuc;
    public String tenTieuThuong;
    public int trangThai;
    public String lyDoKhoa;

    public SapHang(String maSap, String khuVuc, String tenTieuThuong, int trangThai) {
        this(maSap, khuVuc, tenTieuThuong, trangThai, "");
    }

    public SapHang(String maSap, String khuVuc, String tenTieuThuong, int trangThai, String lyDoKhoa) {
        this.maSap = maSap;
        this.khuVuc = khuVuc;
        this.tenTieuThuong = tenTieuThuong;
        this.trangThai = trangThai;
        this.lyDoKhoa = lyDoKhoa;
    }
}