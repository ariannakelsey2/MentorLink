function Navbar({ setPage }) {
  return (
    <div className="navbar">
      <div className="brand">MentorLink</div>

      <div className="nav-links">
        <button type="button" onClick={() => setPage("home")}>Home</button>
        <button type="button" onClick={() => setPage("goals")}>Goals</button>
        <button type="button" onClick={() => setPage("ratings")}>Ratings</button>
        <button type="button" onClick={() => setPage("summary")}>Summary</button>
      </div>
    </div>
  );
}

export default Navbar;