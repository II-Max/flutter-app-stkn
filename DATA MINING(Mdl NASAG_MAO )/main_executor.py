from nasa_data_fetcher import NASADataFetcher
import pandas as pd

class OperationScripter:
    def apply_ai_logic(df):
        if df is None: return None
        
        def determine_actions(row):
            actions = []
            
            # 1. Bảo vệ hệ thống (Mưa & Gió)
            if row['rain'] > 0.4:
                actions.append("DONG_MAI_CHE")
            if row['wind_speed'] > 15:
                actions.append("CANH_BAO_GIO_LON")

            # 2. Điều phối vi khí hậu (Nhiệt độ & Độ ẩm)
            if row['temp_air'] > 32 and row['humidity'] < 50:
                actions.append("PHUN_SUONG_LAM_MAT")
            elif row['humidity'] > 85:
                actions.append("QUAT_THONG_GIO_MAX")
            
            # 3. Quản lý năng lượng & Ánh sáng
            hour = int(row['timestamp'].split(" ")[1].split(":")[0])
            if 6 <= hour <= 18 and row['radiation'] < 120:
                actions.append("BAT_DEN_QUANG_HOP")
                
            return " | ".join(actions) if actions else "DUY_TRI_ON_DINH"

        df['ai_script'] = df.apply(determine_actions, axis=1)
        return df

def main():
    print("=== SMART FARM SYSTEM: KỊCH BẢN TỰ HÀNH ===")
    
    fetcher = NASADataFetcher()
    raw_data = fetcher.fetch_data()
    
    if raw_data is not None:
        scripter = OperationScripter()
        final_plan = scripter.apply_ai_logic(raw_data)
        
        print("\n✅ KỊCH BẢN 24 GIỜ TIẾP THEO:")
        print(final_plan[['timestamp', 'temp_air', 'rain', 'ai_script']].head(12))
        
        final_plan.to_csv("daily_operation_plan.csv", index=False)
        print(f"\n💾 Đã lưu kịch bản vào file: daily_operation_plan.csv")

if __name__ == "__main__":
    main()