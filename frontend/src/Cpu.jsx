import { useState } from 'react';
import { useAuth } from './provider/authProvider';

function Cpu({ id, name, manufacturer, warrantyMonths, price, cores, onDelete, onUpdate, onAddToCart }) {
    const { isAdmin } = useAuth();
    const [isEditing, setIsEditing] = useState(false);

    const [tempName,     setTempName]     = useState(name);
    const [tempMfr,      setTempMfr]      = useState(manufacturer);
    const [tempPrice,    setTempPrice]    = useState(price);
    const [tempWarranty, setTempWarranty] = useState(warrantyMonths);
    const [tempCores,    setTempCores]    = useState(cores);

    const handleSave = () => {
        onUpdate(id, {
            id,
            name:           tempName,
            manufacturer:   tempMfr,
            price:          parseFloat(tempPrice),
            warrantyMonths: parseInt(tempWarranty),
            cores:          parseInt(tempCores),
        });
        setIsEditing(false);
    };

    if (isEditing) {
        return (
            <div className="book-row editing">
                <input type="text"   placeholder="Name"              value={tempName}     onChange={e => setTempName(e.target.value)}     style={{ flex: 2 }} />
                <input type="text"   placeholder="Manufacturer"      value={tempMfr}      onChange={e => setTempMfr(e.target.value)} />
                <input type="number" placeholder="Price"    step="0.01" value={tempPrice}    onChange={e => setTempPrice(e.target.value)} />
                <input type="number" placeholder="Cores"             value={tempCores}    onChange={e => setTempCores(e.target.value)} />
                <input type="number" placeholder="Warranty (months)" value={tempWarranty} onChange={e => setTempWarranty(e.target.value)} />
                <div className="book-actions">
                    <button onClick={handleSave} className="btn-save">Save</button>
                    <button onClick={() => setIsEditing(false)}>Cancel</button>
                </div>
            </div>
        );
    }

    return (
        <div className="book-row">
            <div className="book-info">
                <h3>🖥️ {manufacturer} {name}</h3>
                <p>
                    <strong>Price:</strong> ${Number(price).toFixed(2)} &nbsp;|&nbsp;
                    <strong>Cores:</strong> {cores} &nbsp;|&nbsp;
                    <strong>Warranty:</strong> {warrantyMonths} months
                </p>
            </div>
            <div className="book-actions">
                <button onClick={() => onAddToCart(id)} style={{ backgroundColor: '#28a745', color: 'white' }}>
                    🛒 Add to Cart
                </button>
                {isAdmin && (
                    <>
                        <button onClick={() => setIsEditing(true)} style={{ backgroundColor: '#ffc107' }}>Edit</button>
                        <button onClick={() => onDelete(id)} style={{ backgroundColor: '#ff4444', color: 'white' }}>Delete</button>
                    </>
                )}
            </div>
        </div>
    );
}

export default Cpu;