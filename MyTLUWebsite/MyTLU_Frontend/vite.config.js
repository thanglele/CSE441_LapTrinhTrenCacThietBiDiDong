import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/css/app.css',
                    'resources/css/login.css',
                    'resources/js/app.js'],
            refresh: true,
        }),
        tailwindcss(),
    ],
    server: {
        host: '0.0.0.0',      // lắng nghe mọi interface
        port: 5173,
        strictPort: true,
        hmr: {
            host: 'remote.thanglele.cloud', // HMR sẽ gửi event về host này
            port: 5173,
        },
    },
});
