REM 声明采用UTF-8编码
chcp 65001
scp C:\Users\Admin\Desktop\deploy\V1.5\*.jar root@119.29.146.227:/mnt/skynet/deploy/jarupload

ssh root@119.29.146.227  "/mnt/skynet/deploy/bat_jarservice.sh restart all"

pause