<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Support\Facades\Auth;

class CustomAuthMiddleware
{
    public function handle($request, Closure $next)
    {
        // Kiểm tra nếu chưa đăng nhập thì chuyển về /login
        if (!Auth::check()) {
            return redirect('/login');
        }

        return $next($request);
    }
}
