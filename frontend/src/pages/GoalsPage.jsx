import { useEffect, useState } from "react";
import { getGoals, createGoal, markGoalAchieved } from "../api";

function GoalsPage() {
  const [goals, setGoals] = useState([]);
  const [description, setDescription] = useState("");
  const [mentorshipId, setMentorshipId] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    loadGoals();
  }, []);

  const loadGoals = async () => {
    const data = await getGoals();
    if (Array.isArray(data)) {
      setGoals(data);
      setError("");
    } else {
      setGoals([]);
      setError("Could not load goals.");
      console.log("Goals error:", data);
    }
  };

  const handleAdd = async () => {
    if (!mentorshipId || !description) return;
    await createGoal(mentorshipId, description);
    setDescription("");
    loadGoals();
  };

  const handleAchieve = async (goalId) => {
    await markGoalAchieved(goalId);
    loadGoals();
  };

  return (
    <div className="container">
      <h2>Goals Dashboard</h2>

      <div className="card">
        <h3>Add Goal</h3>
        <input
          placeholder="Mentorship ID"
          value={mentorshipId}
          onChange={(e) => setMentorshipId(e.target.value)}
        />
        <input
          placeholder="Goal Description"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
        />
        <button onClick={handleAdd}>Add Goal</button>
      </div>

      {error && (
        <div className="card">
          <p>{error}</p>
        </div>
      )}

      {goals.map((goal) => (
        <div className="card" key={goal.GoalID}>
          <h4>{goal.Description}</h4>
          <p>Mentorship ID: {goal.MentorshipID}</p>
          <p>Status: {goal.Status}</p>

          {goal.Status !== "Achieved" && (
            <button onClick={() => handleAchieve(goal.GoalID)}>
              Mark Achieved
            </button>
          )}
        </div>
      ))}
    </div>
  );
}

export default GoalsPage;