import { useState } from 'react';
import { useAuth } from './provider/authProvider';

function Gpu({ id, warrantyMonths, vramGB, onDelete, onUpdate, onAddToCart }) {
    // isAdmin is decoded from the JWT payload by authProvider and exposed via context
    const { isAdmin } = useAuth();
    const [isEditing, setIsEditing] = useState(false);

    const [tempWarranty, setTempWarranty] = useState(warrantyMonths);
    const [tempVram,     setTempVram]     = useState(vramGB);

    const handleSave = () => {
        onUpdate(id, {
            id,
            warrantyMonths: parseInt(tempWarranty),
            vramGB:         parseInt(tempVram),
        });
        setIsEditing(false);
    };

    if (isEditing) {
        return (
            <div className="book-row editing">
                <input type="number" placeholder="VRAM (GB)"         value={tempVram}     onChange={e => setTempVram(e.target.value)} />
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
                <h3>🎮 GPU</h3>
                <p>
                    <strong>VRAM:</strong> {vramGB}GB |&nbsp;
                    <strong>Warranty:</strong> {warrantyMonths} months
                </p>
            </div>
            <div className="book-actions">
                <button onClick={() => onAddToCart(id)} style={{ backgroundColor: '#28a745', color: 'white' }}>
                    🛒 Add to Cart
                </button>
                {/* Edit and Delete are hidden from regular users — only Admins see these */}
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

export default Gpu;