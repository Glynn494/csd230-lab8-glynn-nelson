import { Link } from 'react-router';
import { useAuth } from './provider/authProvider';

function Navbar({ cartCount }) {
    // isAdmin comes from the JWT decoded in authProvider — controls which links are visible
    const { isAdmin } = useAuth();

    return (
        <nav className="navbar">
            <Link to="/">🏠 Home</Link>
            <Link to="/inventory">📚 Books</Link>
            <Link to="/magazines">📰 Magazines</Link>
            <Link to="/cpus">🖥️ CPUs</Link>
            <Link to="/gpus">🎮 GPUs</Link>
            <Link to="/cart">🛒 Cart ({cartCount})</Link>

            {/* Add-new links are only shown to Admins */}
            {isAdmin && (
                <>
                    <Link to="/add">➕ Add Book</Link>
                    <Link to="/add-magazine">➕ Add Magazine</Link>
                    <Link to="/add-cpu">➕ Add CPU</Link>
                    <Link to="/add-gpu">➕ Add GPU</Link>
                </>
            )}

            <Link to="/logout" style={{ color: "#ff4444", marginLeft: "auto" }}>🚪 Logout</Link>
        </nav>
    );
}

export default Navbar;