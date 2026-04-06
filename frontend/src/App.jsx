import { useState, useEffect } from 'react';
import { Routes, Route } from 'react-router';
import Navbar from './NavBar';
import Home from './Home';
import Book from './Book';
import BookForm from './BookForm';
import Magazine from './Magazine';
import MagazineForm from './MagazineForm';
import Cpu from './Cpu';
import CpuForm from './CpuForm';
import Gpu from './Gpu';
import GpuForm from './GpuForm';
import Ram from './Ram';
import RamForm from './RamForm';
import Drive from './Drive';
import DriveForm from './DriveForm';
import Cart from './Cart';
import Login from './pages/Login';
import Logout from './pages/Logout';
import SearchableList from './SearchableList';
import { ProtectedRoute } from './routes/ProtectedRoute';
import { useAuth } from './provider/authProvider';
import api from './api/axiosConfig';
import './App.css';

function App() {
    const { token } = useAuth();
    const [books,     setBooks]     = useState([]);
    const [magazines, setMagazines] = useState([]);
    const [cpus,      setCpus]      = useState([]);
    const [gpus,      setGpus]      = useState([]);
    const [rams,      setRams]      = useState([]);
    const [drives,    setDrives]    = useState([]);
    const [cartCount, setCartCount] = useState(0);
    const [loading,   setLoading]   = useState(true);

    useEffect(() => {
        if (!token) { setLoading(false); return; }
        const loadInitialData = async () => {
            try {
                const [booksRes, magsRes, cartRes, cpusRes, gpusRes, ramsRes, drivesRes] =
                    await Promise.all([
                        api.get('/books'),
                        api.get('/magazines'),
                        api.get('/cart'),
                        api.get('/cpus'),
                        api.get('/gpus'),
                        api.get('/ram'),
                        api.get('/drives'),
                    ]);
                setBooks(booksRes.data);
                setMagazines(magsRes.data);
                setCartCount(cartRes.data.products.length);
                setCpus(cpusRes.data);
                setGpus(gpusRes.data);
                setRams(ramsRes.data);
                setDrives(drivesRes.data);
            } catch (err) {
                console.error('Failed to load data', err);
            } finally {
                setLoading(false);
            }
        };
        loadInitialData();
    }, [token]);

    // ── Cart ───────────────────────────────────────────────────────
    const handleAddToCart = async (productId) => {
        try {
            const res = await api.post(`/cart/add/${productId}`);
            setCartCount(res.data.products.length);
            alert('Added to cart!');
        } catch (err) { alert('Error adding to cart'); }
    };

    // ── Books ──────────────────────────────────────────────────────
    const handleDeleteBook = async (id) => {
        if (!window.confirm('Delete book?')) return;
        await api.delete(`/books/${id}`);
        setBooks(books.filter(b => b.id !== id));
    };
    const handleUpdateBook = async (id, data) => {
        const res = await api.put(`/books/${id}`, data);
        setBooks(books.map(b => b.id === id ? res.data : b));
    };

    // ── CPUs ───────────────────────────────────────────────────────
    const handleDeleteCpu = async (id) => {
        if (!window.confirm('Delete CPU?')) return;
        await api.delete(`/cpus/${id}`);
        setCpus(cpus.filter(c => c.id !== id));
    };
    const handleUpdateCpu = async (id, data) => {
        const res = await api.put(`/cpus/${id}`, data);
        setCpus(cpus.map(c => c.id === id ? res.data : c));
    };

    // ── GPUs ───────────────────────────────────────────────────────
    const handleDeleteGpu = async (id) => {
        if (!window.confirm('Delete GPU?')) return;
        await api.delete(`/gpus/${id}`);
        setGpus(gpus.filter(g => g.id !== id));
    };
    const handleUpdateGpu = async (id, data) => {
        const res = await api.put(`/gpus/${id}`, data);
        setGpus(gpus.map(g => g.id === id ? res.data : g));
    };

    // ── RAM ────────────────────────────────────────────────────────
    const handleDeleteRam = async (id) => {
        if (!window.confirm('Delete RAM?')) return;
        await api.delete(`/ram/${id}`);
        setRams(rams.filter(r => r.id !== id));
    };
    const handleUpdateRam = async (id, data) => {
        const res = await api.put(`/ram/${id}`, data);
        setRams(rams.map(r => r.id === id ? res.data : r));
    };

    // ── Drives ─────────────────────────────────────────────────────
    const handleDeleteDrive = async (id) => {
        if (!window.confirm('Delete Drive?')) return;
        await api.delete(`/drives/${id}`);
        setDrives(drives.filter(d => d.id !== id));
    };
    const handleUpdateDrive = async (id, data) => {
        const res = await api.put(`/drives/${id}`, data);
        setDrives(drives.map(d => d.id === id ? res.data : d));
    };

    if (loading) return <h2>Loading...</h2>;

    return (
        <div className="app-container">
            {token && <Navbar cartCount={cartCount} />}

            <Routes>
                {/* PUBLIC */}
                <Route path="/login" element={<Login />} />

                {/* PROTECTED */}
                <Route element={<ProtectedRoute />}>
                    <Route path="/" element={<Home />} />

                    <Route path="/inventory" element={
                        <SearchableList
                            title="Books"
                            items={books}
                            searchKeys={['title', 'author']}
                            renderItem={b => (
                                <Book key={b.id} {...b}
                                      onDelete={handleDeleteBook}
                                      onUpdate={handleUpdateBook}
                                      onAddToCart={handleAddToCart} />
                            )}
                        />
                    } />

                    <Route path="/magazines" element={
                        <SearchableList
                            title="Magazines"
                            items={magazines}
                            searchKeys={['title']}
                            renderItem={m => (
                                <Magazine key={m.id} {...m}
                                          onAddToCart={handleAddToCart}
                                          onDelete={id => api.delete(`/magazines/${id}`).then(() => setMagazines(magazines.filter(mag => mag.id !== id)))}
                                          onUpdate={(id, data) => api.put(`/magazines/${id}`, data).then(res => setMagazines(magazines.map(mag => mag.id === id ? res.data : mag)))} />
                            )}
                        />
                    } />

                    <Route path="/cpus" element={
                        <SearchableList
                            title="CPUs"
                            items={cpus}
                            searchKeys={['name', 'manufacturer']}
                            renderItem={c => (
                                <Cpu key={c.id} {...c}
                                     onDelete={handleDeleteCpu}
                                     onUpdate={handleUpdateCpu}
                                     onAddToCart={handleAddToCart} />
                            )}
                        />
                    } />

                    <Route path="/gpus" element={
                        <SearchableList
                            title="GPUs"
                            items={gpus}
                            searchKeys={['name', 'manufacturer']}
                            renderItem={g => (
                                <Gpu key={g.id} {...g}
                                     onDelete={handleDeleteGpu}
                                     onUpdate={handleUpdateGpu}
                                     onAddToCart={handleAddToCart} />
                            )}
                        />
                    } />

                    <Route path="/ram" element={
                        <SearchableList
                            title="RAM"
                            items={rams}
                            searchKeys={['name', 'manufacturer', 'generation']}
                            renderItem={r => (
                                <Ram key={r.id} {...r}
                                     onDelete={handleDeleteRam}
                                     onUpdate={handleUpdateRam}
                                     onAddToCart={handleAddToCart} />
                            )}
                        />
                    } />

                    <Route path="/drives" element={
                        <SearchableList
                            title="Drives"
                            items={drives}
                            searchKeys={['name', 'manufacturer', 'driveType']}
                            renderItem={d => (
                                <Drive key={d.id} {...d}
                                       onDelete={handleDeleteDrive}
                                       onUpdate={handleUpdateDrive}
                                       onAddToCart={handleAddToCart} />
                            )}
                        />
                    } />

                    <Route path="/cart" element={<Cart api={api} onCartChange={count => setCartCount(count)} />} />

                    <Route path="/add"          element={<BookForm     onBookAdded={b  => setBooks([...books, b])}            api={api} />} />
                    <Route path="/add-magazine" element={<MagazineForm onMagazineAdded={m => setMagazines([...magazines, m])} api={api} />} />
                    <Route path="/add-cpu"      element={<CpuForm      onCpuAdded={c  => setCpus([...cpus, c])}               api={api} />} />
                    <Route path="/add-gpu"      element={<GpuForm      onGpuAdded={g  => setGpus([...gpus, g])}               api={api} />} />
                    <Route path="/add-ram"      element={<RamForm      onRamAdded={r  => setRams([...rams, r])}                api={api} />} />
                    <Route path="/add-drive"    element={<DriveForm    onDriveAdded={d => setDrives([...drives, d])}           api={api} />} />

                    <Route path="/logout" element={<Logout />} />
                </Route>
            </Routes>
        </div>
    );
}

export default App;