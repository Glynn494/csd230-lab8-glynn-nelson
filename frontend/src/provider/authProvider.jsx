import { createContext, useContext, useMemo, useState, useEffect, useCallback } from "react";

const AuthContext = createContext();

const AuthProvider = ({ children }) => {
    const [token, setToken_] = useState(localStorage.getItem("token"));

    // ── Helper: decode the JWT payload ───────────────────────────────────────
    // Uses regex with the 'g' flag to replace ALL '-' and '_' occurrences
    // in the base64url string before passing to atob() — the robust approach.
    const decodeToken = (t) => {
        if (!t) return null;
        try {
            const base64Url = t.split('.')[1];
            const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
            return JSON.parse(window.atob(base64));
        } catch (e) {
            console.error("Failed to decode token", e);
            return null;
        }
    };

    // ── Helper: check if the JWT exp claim is in the past ────────────────────
    // JWT 'exp' is in seconds; Date.now() is in milliseconds.
    const isTokenExpired = useCallback((t) => {
        const payload = decodeToken(t);
        if (!payload || !payload.exp) return true;
        return payload.exp * 1000 < Date.now();
    }, []);

    // ── Proactive expiry check ────────────────────────────────────────────────
    // Runs on mount and whenever the token changes.
    // Also sets a timer that fires exactly when the token expires, so any open
    // tab is redirected automatically without needing the user to click anything.
    useEffect(() => {
        if (!token) return;

        // If the token is already expired when the component mounts, kick out now.
        if (isTokenExpired(token)) {
            console.warn("Token already expired on load. Redirecting...");
            localStorage.removeItem("token");
            setToken_(null);
            window.location.href = "/login?expired=true";
            return;
        }

        // Calculate exactly how many milliseconds remain until the token expires.
        const payload = decodeToken(token);
        const msUntilExpiry = payload.exp * 1000 - Date.now();

        // Set a timer to auto-logout the moment the token expires.
        // This means EVERY button (Add to Cart, Edit, Delete, etc.) will stop
        // working at the right time — the user is redirected before they can click.
        const timer = setTimeout(() => {
            console.warn("Token expired. Redirecting to login...");
            localStorage.removeItem("token");
            setToken_(null);
            window.location.href = "/login?expired=true";
        }, msUntilExpiry);

        // Clean up the timer if the token changes (e.g. on logout) before it fires.
        return () => clearTimeout(timer);
    }, [token, isTokenExpired]);

    // ── Extract roles from token payload ─────────────────────────────────────
    const getRolesFromToken = (t) => {
        const payload = decodeToken(t);
        return payload?.roles || [];
    };

    const roles = useMemo(() => getRolesFromToken(token), [token]);

    // ── setToken: persists to localStorage and updates React state ───────────
    const setToken = (newToken) => {
        setToken_(newToken);
        if (newToken) {
            localStorage.setItem("token", newToken);
        } else {
            localStorage.removeItem("token");
        }
    };

    const contextValue = useMemo(
        () => ({
            token,
            roles,
            isAdmin: roles.includes("ROLE_ADMIN"),
            setToken,
        }),
        [token, roles]
    );

    return (
        <AuthContext.Provider value={contextValue}>
            {children}
        </AuthContext.Provider>
    );
};

export const useAuth = () => useContext(AuthContext);
export default AuthProvider;