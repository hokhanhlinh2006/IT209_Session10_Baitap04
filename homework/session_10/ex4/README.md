# Bài 4: Custom Network & Named Volume

## Thông tin sinh viên
- Họ và tên: Hồ Khánh Linh
- Mã sinh viên: B24DTCN359
- Lớp: CNTT3

## Mục tiêu
Tạo Custom Bridge Network và Named Volume bằng Docker CLI.

## Thành phần
- Network: app-net
- Volume: db-data
- Database: db-server
- Backend: app-container
- PostgreSQL: postgres:15-alpine

## Cách chạy
    chmod +x commands.sh
    ./commands.sh

## Kiểm tra
    docker network ls | grep app-net
    docker volume ls | grep db-data
    docker network inspect app-net
    docker exec app-container ping -c 2 db-server
    docker exec db-server psql -U appuser -d appdb -c "SELECT * FROM demo;"

## Kết quả
Backend phân giải được hostname db-server. Dữ liệu PostgreSQL vẫn tồn tại sau khi xóa và tạo lại container nhờ Volume db-data.

## Kết luận
Hoàn thành cấu hình Custom Network và Named Volume bằng Docker CLI.
<img width="660" height="582" alt="ex4_ss10" src="https://github.com/user-attachments/assets/cf58e68c-3214-4686-8da3-9448ef34d6b3" />

