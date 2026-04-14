export default function SummaryCard({ summary }) {
  if (!summary) {
    return null
  }

  return (
    <div className="card">
      <h2>Mentorship Summary</h2>
      <p><strong>Mentorship ID:</strong> {summary.MentorshipID}</p>
      <p><strong>Total Goals:</strong> {summary.TotalGoals}</p>
      <p><strong>Achieved Goals:</strong> {summary.AchievedGoals}</p>
      <p><strong>Completion Percent:</strong> {summary.CompletionPercent}%</p>
      <p><strong>Average Rating Score:</strong> {summary.AverageRatingScore ?? 'No ratings yet'}</p>
    </div>
  )
}
