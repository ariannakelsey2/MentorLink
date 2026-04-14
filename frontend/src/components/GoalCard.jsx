export default function GoalCard({ goal, onAchieve }) {
  return (
    <div className="card">
      <h3>{goal.Description}</h3>
      <p><strong>Goal ID:</strong> {goal.GoalID}</p>
      <p><strong>Mentorship ID:</strong> {goal.MentorshipID}</p>
      <p><strong>Status:</strong> {goal.Status}</p>
      {goal.Status !== 'Achieved' && (
        <button onClick={() => onAchieve(goal.GoalID)}>Mark Achieved</button>
      )}
    </div>
  )
}
