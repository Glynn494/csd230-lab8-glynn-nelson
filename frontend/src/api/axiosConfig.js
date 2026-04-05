import axios from 'axios';

const api = axios.create({
    baseURL: '/api/rest'
});

// REQUEST Interceptor: Attaches the JWT Bearer token to every outgoing request.
api.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem('token');
        if (token) {
            config.headers['Authorization'] = `Bearer ${token}`;
        }
        return config;
    },
    (error) => {
        return Promise.reject(error);
    }
);

// RESPONSE Interceptor: Handles data returning from the server.
api.interceptors.response.use(
    (response) => {
        return response; // Success (2xx) — pass through unchanged
    },
    (error) => {
        // Handle 401 Unauthorized (expired/invalid token) or 403 Forbidden (wrong role).
        if (error.response && (error.response.status === 401 || error.response.status === 403)) {
            console.warn("Security error detected. Redirecting to login...");

            // 1. Wipe the stale token from storage so the app starts clean.
            localStorage.removeItem('token');

            // 2. Hard redirect to the Login page with an 'expired' flag in the URL.
            //    Login.jsx reads this param and shows a "session expired" warning banner.
            window.location.href = '/login?expired=true';
        }
        return Promise.reject(error);
    }
);

export default api;