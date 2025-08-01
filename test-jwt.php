<?php
/**
 * Kong JWT 认证测试脚本 (PHP 版本)
 * 生成 JWT token 并测试受保护的端点
 */

// JWT 配置 (与 jwt-clean.yaml 中的配置保持一致)
define('JWT_SECRET', 'production-secret-key-2025');  // 匹配新的生产配置
define('JWT_ISSUER', 'production-issuer');  // 匹配新的生产配置
define('JWT_ALGORITHM', 'HS256');

/**
 * Base64 URL 编码
 */
function base64UrlEncode($data) {
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

/**
 * 生成 JWT token
 */
function generateJwtToken($userId = 'test-user', $expiresInHours = 1) {
    // JWT Header
    $header = json_encode([
        'typ' => 'JWT',
        'alg' => JWT_ALGORITHM
    ]);
    $now = time();
    // JWT Payload
    $payload = json_encode([
        'iss' => JWT_ISSUER,  // 发行者，必须与 Kong 配置中的 key 匹配
        'sub' => $userId,     // 主题 (用户ID)
        'iat' => $now,      // 签发时间
        'nbf' => $now,      // 生效时间
        'exp' => $now + ($expiresInHours * 3600), // 过期时间
        'roles' => ['user']
    ]);
    
    // Base64 编码
    $headerEncoded = base64UrlEncode($header);
    $payloadEncoded = base64UrlEncode($payload);
    
    // 创建签名
    $signature = hash_hmac('sha256', $headerEncoded . '.' . $payloadEncoded, JWT_SECRET, true);
    $signatureEncoded = base64UrlEncode($signature);
    
    // 组合 JWT
    return $headerEncoded . '.' . $payloadEncoded . '.' . $signatureEncoded;
}

/**
 * 解码 JWT token (简单验证)
 */
function decodeJwtToken($token) {
    $parts = explode('.', $token);
    if (count($parts) !== 3) {
        return false;
    }
    
    $payload = json_decode(base64_decode(strtr($parts[1], '-_', '+/')), true);
    return $payload;
}

/**
 * 测试受保护的端点
 */
function testProtectedEndpoint($token = null) {
    $url = 'http://localhost/';
    $headers = [
        'Host: protected.local'
    ];
    
    if ($token) {
        $headers[] = 'Authorization: Bearer ' . $token;
    }
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HEADER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 10);
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $headerSize = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
    
    if (curl_error($ch)) {
        echo "请求失败: " . curl_error($ch) . "\n";
        curl_close($ch);
        return false;
    }
    
    $headers = substr($response, 0, $headerSize);
    $body = substr($response, $headerSize);
    
    echo "状态码: $httpCode\n";
    echo "响应头:\n$headers\n";
    
    if ($body) {
        $jsonData = json_decode($body, true);
        if ($jsonData) {
            echo "响应内容:\n" . json_encode($jsonData, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
        } else {
            echo "响应内容: $body\n";
        }
    }
    
    echo str_repeat('-', 50) . "\n";
    
    curl_close($ch);
    return $httpCode == 200;
}

/**
 * 主函数
 */
function main() {
    echo "=== Kong JWT 认证测试 (PHP 版本) ===\n\n";
    
    // 1. 测试无 token 访问 (应该被拒绝)
    echo "1. 测试无 token 访问:\n";
    testProtectedEndpoint();
    
    // 2. 生成有效的 JWT token
    echo "2. 生成 JWT token:\n";
    $token = generateJwtToken(8241);
    echo "生成的 token: $token\n\n";
    
    // 3. 使用有效 token 访问
    echo "3. 使用有效 token 访问:\n";
    testProtectedEndpoint($token);
    
    // 4. 解码 token 查看内容
    echo "4. Token 内容:\n";
    $decoded = decodeJwtToken($token);
    if ($decoded) {
        echo json_encode($decoded, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
    } else {
        echo "解码失败\n";
    }
    
    echo "\n=== 测试完成 ===\n";
    echo "如果需要手动测试，可以使用以下命令:\n";
    echo "curl -H 'Host: protected.local' -H 'Authorization: Bearer $token' http://localhost/\n";
}

// 检查是否从命令行运行
if (php_sapi_name() === 'cli') {
    main();
} else {
    echo "请从命令行运行此脚本: php test-jwt.php\n";
}
?>
