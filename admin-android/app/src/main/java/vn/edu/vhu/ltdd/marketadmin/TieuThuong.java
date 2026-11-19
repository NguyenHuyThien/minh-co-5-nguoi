package vn.edu.vhu.ltdd.marketadmin;

import java.util.ArrayList;
import java.util.List;

public class TieuThuong {
    public String maTT;
    public String hoTen;
    public String soDienThoai;
    public String maSap;
    public String khuVuc;
    public int trangThai;
    public String lyDo;
    public List<String> lichSuViPham;

    public TieuThuong(String maTT, String hoTen, String soDienThoai, String maSap, String khuVuc, int trangThai, String lyDo) {
        this.maTT = maTT;
        this.hoTen = hoTen;
        this.soDienThoai = soDienThoai;
        this.maSap = maSap;
        this.khuVuc = khuVuc;
        this.trangThai = trangThai;
        this.lyDo = lyDo;
        this.lichSuViPham = new ArrayList<>();
    }
}