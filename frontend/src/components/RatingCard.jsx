export default function RatingCard({ rating }) {
  return (
    <div className="card">
      <h3>{rating.RatingValue}</h3>
      <p><strong>Rating ID:</strong> {rating.RatingID}</p>
      <p><strong>Mentorship ID:</strong> {rating.MentorshipID}</p>
      <p><strong>Rater User ID:</strong> {rating.RaterUserID}</p>
      <p><strong>Rated User ID:</strong> {rating.RatedUserID}</p>
      <p><strong>Date:</strong> {rating.RatingDate || 'N/A'}</p>
    </div>
  )
}
