import { Link } from 'react-router';
import { useAuth } from './provider/authProvider';

function Navbar({ cartCount }) {
    const { isAdmin } = useAuth();

    return (
        <nav className="navbar">
            <Link to="/">🏠 Home</Link>
            <Link to="/inventory">📚 Books</Link>
            <Link to="/magazines">📰 Magazines</Link>
            <Link to="/cpus">🖥️ CPUs</Link>
            <Link to="/gpus">🎮 GPUs</Link>
            <Link to="/ram">🧠 RAM</Link>
            <Link to="/drives">💾 Drives</Link>
            <Link to="/cart">🛒 Cart ({cartCount})</Link>

            {isAdmin && (
                <>
                    <Link to="/add">➕ Book</Link>
                    <Link to="/add-magazine">➕ Mag</Link>
                    <Link to="/add-cpu">➕ CPU</Link>
                    <Link to="/add-gpu">➕ GPU</Link>
                    <Link to="/add-ram">➕ RAM</Link>
                    <Link to="/add-drive">➕ Drive</Link>
                </>
            )}

            <Link to="/logout" style={{ color: '#ff4444', marginLeft: 'auto' }}>🚪 Logout</Link>
        </nav>
    );
}

export default Navbar;