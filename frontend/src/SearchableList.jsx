import { useState } from 'react';

/**
 * SearchableList
 *
 * Props:
 *   title      — section heading string, e.g. "Books"
 *   items      — full array of objects from state
 *   searchKeys — array of property names to match against, e.g. ['title', 'author']
 *   renderItem — function(item) => JSX, renders one row
 */
function SearchableList({ title, items, searchKeys, renderItem }) {
    const [query, setQuery] = useState('');

    const filtered = query.trim() === ''
        ? items
        : items.filter(item =>
            searchKeys.some(key => {
                const val = item[key];
                return val && String(val).toLowerCase().includes(query.toLowerCase());
            })
        );

    return (
        <div className="book-list">
            <div className="list-header">
                <h1>{title}</h1>
                <div className="search-bar">
                    <span className="search-icon">🔍</span>
                    <input
                        type="text"
                        placeholder={`Search ${title.toLowerCase()}…`}
                        value={query}
                        onChange={e => setQuery(e.target.value)}
                    />
                    {query && (
                        <button className="search-clear" onClick={() => setQuery('')} title="Clear">✕</button>
                    )}
                </div>
            </div>

            {filtered.length === 0 ? (
                <p className="search-empty">No {title.toLowerCase()} match &ldquo;{query}&rdquo;.</p>
            ) : (
                filtered.map(item => renderItem(item))
            )}
        </div>
    );
}

export default SearchableList;