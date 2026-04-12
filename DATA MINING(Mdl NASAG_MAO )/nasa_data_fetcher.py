import requests
import pandas as pd
from datetime import datetime, timedelta

class NASADataFetcher:
    def __init__(self):
        self.DEFAULT_LAT = 21.0285
        self.DEFAULT_LON = 105.8542
        self.BASE_URL = "***"
        self.PARAMS = "***"

    def get_location(self):
        print(f"\n📍 Vị trí hiện tại (Mặc định): Hà Nội ({self.DEFAULT_LAT}, {self.DEFAULT_LON})")
        choice = input("👉 Nhấn Enter để dùng mặc định, hoặc 'y' để đổi vị trí: ").strip().lower()
        if choice == 'y':
            try:
                lat = float(input("   - Nhập Vĩ độ (Lat): ").strip())
                lon = float(input("   - Nhập Kinh độ (Lon): ").strip())
                return lat, lon
            except ValueError:
                print("⚠️ Lỗi nhập liệu! Dùng tọa độ Hà Nội.")
        return self.DEFAULT_LAT, self.DEFAULT_LON

    def get_time_range(self):
        print("\n📅 KHOẢNG THỜI GIAN DỰ BÁO: (1) 1 ngày | (2) 3 ngày | (3) 7 ngày | (4) Custom")
        choice = input("👉 Chọn (1-4): ").strip()
        today = datetime.now()
        
        if choice == '2':
            start, end = today.strftime('%Y%m%d'), (today + timedelta(days=2)).strftime('%Y%m%d')
        elif choice == '3':
            start, end = today.strftime('%Y%m%d'), (today + timedelta(days=6)).strftime('%Y%m%d')
        elif choice == '4':
            time_input = input("👉 Nhập (YYYYMMDD-YYYYMMDD): ").strip()
            start, end = time_input.split('-')
        else:
            start = end = today.strftime('%Y%m%d')
        return start, end

    def fetch_data(self):
        lat, lon = self.get_location()
        start, end = self.get_time_range()
        payload = {"parameters": self.PARAMS, "community": "AG", "longitude": lon, "latitude": lat, "start": start, "end": end, "format": "JSON"}
        
        try:
            print(f"⏳ Đang kết nối NASA...")
            response = requests.get(self.BASE_URL, params=payload, timeout=25)
            response.raise_for_status()
            df = pd.DataFrame(response.json()['properties']['parameter'])
            df = df.reset_index().rename(columns={'index': 'timestamp'})
            df['timestamp'] = pd.to_datetime(df['timestamp'], format='%Y%m%d%H').dt.strftime('%Y-%m-%d %H:00')
            df = df.rename(columns={'T2M': 'temp_air', 'TS': 'temp_soil', 'PRECTOTCORR': 'rain', 'RH2M': 'humidity', 'WS10M': 'wind_speed', 'ALLSKY_SFC_SW_DWN': 'radiation'})
            return df
        except Exception as e:
            print(f"❌ Lỗi: {e}")
            return None

# ĐOẠN LỆNH ĐỂ CHẠY THỬ FILE 1 ĐỘC LẬP
if __name__ == "__main__":
    fetcher = NASADataFetcher()
    data = fetcher.fetch_data()
    if data is not None:
        print(data.head())