package vn.edu.vhu.ltdd.marketadmin;

import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import java.util.List;

public class TieuThuongAdapter extends RecyclerView.Adapter<TieuThuongAdapter.ViewHolder> {

    public interface OnTieuThuongClickListener {
        void onTieuThuongClick(TieuThuong tt);
    }

    private List<TieuThuong> dsTieuThuong;
    private final OnTieuThuongClickListener listener;

    public TieuThuongAdapter(List<TieuThuong> dsTieuThuong, OnTieuThuongClickListener listener) {
        this.dsTieuThuong = dsTieuThuong;
        this.listener = listener;
    }

    public void updateData(List<TieuThuong> newList) {
        this.dsTieuThuong = newList;
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_tieu_thuong, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        TieuThuong tt = dsTieuThuong.get(position);
        holder.tvMaTT.setText("Tiểu thương " + tt.maTT);
        holder.tvKhuVucNho.setText(tt.khuVuc);
        holder.tvHoTen.setText("Chủ sạp: " + tt.hoTen);
        holder.tvSdt.setText("SĐT: " + dinhDangSdt(tt.soDienThoai));

        if (tt.hoTen.contains("Cô") || tt.hoTen.contains("Bà") || tt.hoTen.contains("Chị")) {
            holder.ivAvatar.setImageResource(android.R.drawable.ic_menu_myplaces);
            holder.ivAvatar.setColorFilter(Color.parseColor("#EC4899"));
        } else {
            holder.ivAvatar.setImageResource(android.R.drawable.ic_menu_myplaces);
            holder.ivAvatar.setColorFilter(Color.parseColor("#0F766E"));
        }

        if (tt.trangThai == 1) {
            holder.tvTrangThai.setText("Hoạt động");
            holder.tvTrangThai.setTextColor(Color.parseColor("#15803D"));
            holder.tvTrangThai.setBackgroundColor(Color.parseColor("#DCFCE7"));
            holder.tvLyDo.setVisibility(View.GONE);
        } else if (tt.trangThai == 0) {
            holder.tvTrangThai.setText("Tạm ngưng");
            holder.tvTrangThai.setTextColor(Color.parseColor("#475569"));
            holder.tvTrangThai.setBackgroundColor(Color.parseColor("#E2E8F0"));
            holder.tvLyDo.setVisibility(View.VISIBLE);
            holder.tvLyDo.setTextColor(Color.parseColor("#475569"));
            holder.tvLyDo.setText("Lý do: " + (tt.lyDo != null && !tt.lyDo.isEmpty() ? tt.lyDo : "Chưa cập nhật"));
        } else {
            holder.tvTrangThai.setText("Đã khóa");
            holder.tvTrangThai.setTextColor(Color.parseColor("#B91C1C"));
            holder.tvTrangThai.setBackgroundColor(Color.parseColor("#FEE2E2"));
            holder.tvLyDo.setVisibility(View.VISIBLE);
            holder.tvLyDo.setTextColor(Color.parseColor("#B91C1C"));
            holder.tvLyDo.setText("Lý do: " + (tt.lyDo != null && !tt.lyDo.isEmpty() ? tt.lyDo : "Chưa cập nhật"));
        }

        holder.itemView.setOnClickListener(v -> listener.onTieuThuongClick(tt));
    }

    private String dinhDangSdt(String sdt) {
        if (sdt == null || sdt.length() < 10) return sdt;
        return sdt.substring(0, 4) + " " + sdt.substring(4, 7) + " " + sdt.substring(7);
    }

    @Override
    public int getItemCount() {
        return dsTieuThuong.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView ivAvatar;
        TextView tvMaTT, tvKhuVucNho, tvHoTen, tvSdt, tvLyDo, tvTrangThai;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            ivAvatar = itemView.findViewById(R.id.ivAvatarTT);
            tvMaTT = itemView.findViewById(R.id.tvMaTT);
            tvKhuVucNho = itemView.findViewById(R.id.tvKhuVucNho);
            tvHoTen = itemView.findViewById(R.id.tvHoTenTT);
            tvSdt = itemView.findViewById(R.id.tvSdtTT);
            tvLyDo = itemView.findViewById(R.id.tvLyDoTT);
            tvTrangThai = itemView.findViewById(R.id.tvTrangThaiTT);
        }
    }
}