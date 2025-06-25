<?php
/**
 * 示例PHP应用
 * 展示nginx+php-fpm镜像的功能
 */

// 设置错误报告
error_reporting(E_ALL);
ini_set('display_errors', 1);

// 获取请求信息
$requestUri = $_SERVER['REQUEST_URI'] ?? '/';
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
$userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown';

?>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nginx + PHP-FPM 示例应用</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #333;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .header {
            background: #2c3e50;
            color: white;
            padding: 30px;
            text-align: center;
        }
        .content {
            padding: 30px;
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        .info-card {
            background: #f8f9fa;
            border-left: 4px solid #3498db;
            padding: 20px;
            border-radius: 5px;
        }
        .info-card h3 {
            margin-top: 0;
            color: #2c3e50;
        }
        .status {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }
        .status.success { background: #d4edda; color: #155724; }
        .status.info { background: #d1ecf1; color: #0c5460; }
        .footer {
            background: #ecf0f1;
            padding: 20px;
            text-align: center;
            color: #7f8c8d;
        }
        pre {
            background: #2c3e50;
            color: #ecf0f1;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 Nginx + PHP-FPM Docker 镜像</h1>
            <p>通用Web服务器环境 - 运行正常</p>
            <span class="status success">✅ 服务正常</span>
        </div>
        
        <div class="content">
            <div class="info-grid">
                <div class="info-card">
                    <h3>🐘 PHP 信息</h3>
                    <p><strong>版本:</strong> <?php echo PHP_VERSION; ?></p>
                    <p><strong>SAPI:</strong> <?php echo php_sapi_name(); ?></p>
                    <p><strong>内存限制:</strong> <?php echo ini_get('memory_limit'); ?></p>
                    <p><strong>上传限制:</strong> <?php echo ini_get('upload_max_filesize'); ?></p>
                </div>
                
                <div class="info-card">
                    <h3>🌐 服务器信息</h3>
                    <p><strong>服务器软件:</strong> <?php echo $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown'; ?></p>
                    <p><strong>请求方法:</strong> <?php echo $method; ?></p>
                    <p><strong>请求URI:</strong> <?php echo htmlspecialchars($requestUri); ?></p>
                    <p><strong>服务器时间:</strong> <?php echo date('Y-m-d H:i:s'); ?></p>
                </div>
                
                <div class="info-card">
                    <h3>🔧 已安装扩展</h3>
                    <?php
                    $extensions = ['pdo_mysql', 'pdo_pgsql', 'pgsql', 'mysqli', 'opcache', 'curl', 'json', 'mbstring'];
                    foreach ($extensions as $ext) {
                        $status = extension_loaded($ext) ? 'success' : 'info';
                        $icon = extension_loaded($ext) ? '✅' : '❌';
                        echo "<span class='status $status'>$icon $ext</span> ";
                    }
                    ?>
                </div>
                
                <div class="info-card">
                    <h3>📊 系统状态</h3>
                    <p><strong>负载:</strong> <?php echo sys_getloadavg()[0] ?? 'N/A'; ?></p>
                    <p><strong>内存使用:</strong> <?php echo round(memory_get_usage(true) / 1024 / 1024, 2); ?> MB</p>
                    <p><strong>峰值内存:</strong> <?php echo round(memory_get_peak_usage(true) / 1024 / 1024, 2); ?> MB</p>
                    <p><strong>时区:</strong> <?php echo date_default_timezone_get(); ?></p>
                </div>
            </div>
            
            <div class="info-card">
                <h3>🔗 数据库连接测试</h3>
                <?php
                // MySQL连接测试
                echo "<h4>MySQL:</h4>";
                try {
                    $mysql_host = getenv('MYSQL_HOST') ?: 'mysql';
                    $mysql_db = getenv('MYSQL_DATABASE') ?: 'webapp';
                    $mysql_user = getenv('MYSQL_USER') ?: 'webapp';
                    $mysql_pass = getenv('MYSQL_PASSWORD') ?: 'password';
                    
                    $pdo = new PDO("mysql:host=$mysql_host;dbname=$mysql_db", $mysql_user, $mysql_pass);
                    echo "<span class='status success'>✅ MySQL连接成功</span>";
                } catch (Exception $e) {
                    echo "<span class='status info'>ℹ️ MySQL未配置或连接失败</span>";
                }
                
                // PostgreSQL连接测试
                echo "<h4>PostgreSQL:</h4>";
                try {
                    $pg_host = getenv('POSTGRES_HOST') ?: 'postgres';
                    $pg_db = getenv('POSTGRES_DB') ?: 'webapp';
                    $pg_user = getenv('POSTGRES_USER') ?: 'webapp';
                    $pg_pass = getenv('POSTGRES_PASSWORD') ?: 'password';
                    
                    $pdo = new PDO("pgsql:host=$pg_host;dbname=$pg_db", $pg_user, $pg_pass);
                    echo "<span class='status success'>✅ PostgreSQL连接成功</span>";
                } catch (Exception $e) {
                    echo "<span class='status info'>ℹ️ PostgreSQL未配置或连接失败</span>";
                }
                ?>
            </div>
            
            <div class="info-card">
                <h3>📝 环境变量</h3>
                <pre><?php
                $env_vars = ['TZ', 'PHP_INI_DIR', 'PHP_CFLAGS', 'PHP_VERSION'];
                foreach ($env_vars as $var) {
                    $value = getenv($var) ?: 'Not set';
                    echo "$var: $value\n";
                }
                ?></pre>
            </div>
        </div>
        
        <div class="footer">
            <p>🐳 Common Nginx + PHP-FPM Docker Image</p>
            <p>访问 <a href="/health">/health</a> 进行健康检查</p>
        </div>
    </div>
</body>
</html>
