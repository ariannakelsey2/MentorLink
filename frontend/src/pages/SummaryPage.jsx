import { useState } from "react";
import { getSummary } from "../api";

function SummaryPage() {
  const [mentorshipId, setMentorshipId] = useState("");
  const [summary, setSummary] = useState(null);
  const [error, setError] = useState("");

  const loadSummary = async () => {
    if (!mentorshipId) return;

    const data = await getSummary(mentorshipId);

    if (data && !data.error) {
      setSummary(data);
      setError("");
    } else {
      setSummary(null);
      setError("Failed to load summary.");
      console.log("Summary error:", data);
    }
  };

  return (
    <div className="container">
      <h2>Mentorship Summary</h2>

      <div className="card">
        <input
          placeholder="Mentorship ID"
          value={mentorshipId}
          onChange={(e) => setMentorshipId(e.target.value)}
        />
        <button onClick={loadSummary}>Load Summary</button>
      </div>

      {error && (
        <div className="card">
          <p>{error}</p>
        </div>
      )}

      {summary && (
        <div className="card">
          <h3>Results</h3>
          <p>Achieved Goals: {summary.AchievedGoals}</p>
          <p>Total Goals: {summary.TotalGoals}</p>
        </div>
      )}
    </div>
  );
}

export default SummaryPage;