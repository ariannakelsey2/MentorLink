function HomePage({ setPage }) {
  return (
    <div className="container home-center">
      <img src="/logo.png" width="220" alt="MentorLink logo" className="logo" />

      <h1>MentorLink Dashboard</h1>
      <p>Manage mentorship goals and feedback</p>

      <div className="home-actions">
        <button type="button" onClick={() => setPage("goals")}>Goals</button>
        <button type="button" onClick={() => setPage("ratings")}>Ratings</button>
        <button type="button" onClick={() => setPage("summary")}>Summary</button>
      </div>
    </div>
  );
}

export default HomePage;