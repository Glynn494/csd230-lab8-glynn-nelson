import { useState } from 'react';
import { useAuth } from './provider/authProvider';

function Drive({ id, name, manufacturer, warrantyMonths, price, storageGB, driveType,
                   readSpeedMBs, writeSpeedMBs, onDelete, onUpdate, onAddToCart }) {
    const { isAdmin } = useAuth();
    const [isEditing, setIsEditing] = useState(false);

    const [tempName,     setTempName]     = useState(name);
    const [tempMfr,      setTempMfr]      = useState(manufacturer);
    const [tempPrice,    setTempPrice]    = useState(price);
    const [tempStorage,  setTempStorage]  = useState(storageGB);
    const [tempType,     setTempType]     = useState(driveType);
    const [tempRead,     setTempRead]     = useState(readSpeedMBs);
    const [tempWrite,    setTempWrite]    = useState(writeSpeedMBs);
    const [tempWarranty, setTempWarranty] = useState(warrantyMonths);

    const handleSave = () => {
        onUpdate(id, {
            id,
            name:           tempName,
            manufacturer:   tempMfr,
            price:          parseFloat(tempPrice),
            storageGB:      parseInt(tempStorage),
            driveType:      tempType,
            readSpeedMBs:   parseInt(tempRead),
            writeSpeedMBs:  parseInt(tempWrite),
            warrantyMonths: parseInt(tempWarranty),
        });
        setIsEditing(false);
    };

    if (isEditing) {
        return (
            <div className="book-row editing">
                <input type="text"   placeholder="Name"              value={tempName}     onChange={e => setTempName(e.target.value)}     style={{ flex: 2 }} />
                <input type="text"   placeholder="Manufacturer"      value={tempMfr}      onChange={e => setTempMfr(e.target.value)} />
                <input type="number" placeholder="Price"   step="0.01" value={tempPrice}    onChange={e => setTempPrice(e.target.value)} />
                <input type="number" placeholder="Storage (GB)"      value={tempStorage}  onChange={e => setTempStorage(e.target.value)} />
                <select value={tempType} onChange={e => setTempType(e.target.value)}>
                    <option value="SSD">SSD</option>
                    <option value="HDD">HDD</option>
                </select>
                <input type="number" placeholder="Read Speed (MB/s)" value={tempRead}     onChange={e => setTempRead(e.target.value)} />
                <input type="number" placeholder="Write Speed (MB/s)"value={tempWrite}    onChange={e => setTempWrite(e.target.value)} />
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
                <h3>
                    💾 {manufacturer} {name}
                    <span style={{ fontSize: '0.75rem', fontWeight: 400, color: 'var(--text-muted)', marginLeft: '6px' }}>
                        {driveType}
                    </span>
                </h3>
                <p>
                    <strong>Price:</strong> ${Number(price).toFixed(2)} &nbsp;|&nbsp;
                    <strong>Storage:</strong> {storageGB >= 1000 ? `${storageGB / 1000} TB` : `${storageGB} GB`} &nbsp;|&nbsp;
                    <strong>Read:</strong> {readSpeedMBs} MB/s &nbsp;|&nbsp;
                    <strong>Write:</strong> {writeSpeedMBs} MB/s &nbsp;|&nbsp;
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

export default Drive;