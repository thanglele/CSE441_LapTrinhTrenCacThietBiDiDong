<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session; // Import Session

class EnsureUserIsAuthenticated
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */
    public function handle(Request $request, Closure $next)
    {
        // Kiểm tra xem session 'auth_token' (đã lưu ở Controller) có tồn tại không
        if (!Session::has('auth_token')) {
            // Nếu không có, đá về trang login
            return redirect()->route('login');
        }

        // Nếu có, cho phép request đi tiếp
        return $next($request);
    }
}
