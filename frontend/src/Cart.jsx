import { useState, useEffect } from 'react';

/**
 * Resolves a human-readable display name for any product type returned by the API.
 * Books/Magazines have `title`; Tickets have `description`;
 * Hardware (CPU, GPU, RAM, Drive) has `name` and optionally `manufacturer`.
 */
function getProductName(p) {
    if (p.title)        return p.title;                          // Book, Magazine
    if (p.description)  return p.description;                    // Ticket
    if (p.name)         return p.manufacturer
        ? `${p.manufacturer} ${p.name}`
        : p.name;                     // CPU, GPU, RAM, Drive
    return `Product #${p.id}`;
}

/**
 * Returns a readable price string. Hardware entities currently return 0.0 from getPrice();
 * this gracefully shows "—" in that case so the cart doesn't look broken.
 */
function getProductPrice(p) {
    const price = p.price ?? p.pub_price ?? 0;
    return price > 0 ? `$${Number(price).toFixed(2)}` : '—';
}

function Cart({ api, onCartChange }) {
    const [cart, setCart] = useState(null);

    const loadCart = async () => {
        const res = await api.get('/cart');
        setCart(res.data);
        onCartChange(res.data.products.length);
    };

    useEffect(() => { loadCart(); }, []);

    const handleRemove = async (id) => {
        await api.delete(`/cart/remove/${id}`);
        loadCart();
    };

    if (!cart) return <p>Loading...</p>;

    const total = cart.products.reduce((sum, p) => {
        const price = p.price ?? p.pub_price ?? 0;
        return sum + Number(price);
    }, 0);

    return (
        <div>
            <h1>Your Cart</h1>
            {cart.products.length === 0 ? (
                <p>Your cart is empty.</p>
            ) : (
                <>
                    <table>
                        <thead>
                        <tr>
                            <th>Item</th>
                            <th>Type</th>
                            <th>Price</th>
                            <th>Action</th>
                        </tr>
                        </thead>
                        <tbody>
                        {cart.products.map(p => (
                            <tr key={p.id}>
                                <td>{getProductName(p)}</td>
                                <td>{p.productType}</td>
                                <td>{getProductPrice(p)}</td>
                                <td>
                                    <button onClick={() => handleRemove(p.id)}>Remove</button>
                                </td>
                            </tr>
                        ))}
                        </tbody>
                    </table>
                    {total > 0 && (
                        <p style={{ marginTop: '1rem', textAlign: 'right', fontWeight: 600, color: 'var(--text-primary)' }}>
                            Total: <span style={{ color: 'var(--accent)' }}>${total.toFixed(2)}</span>
                        </p>
                    )}
                </>
            )}
        </div>
    );
}

export default Cart;