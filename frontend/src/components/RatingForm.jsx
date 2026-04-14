import { useState } from 'react'

export default function RatingForm({ onCreate }) {
  const [formData, setFormData] = useState({
    mentorship_id: '',
    rater_user_id: '',
    rated_user_id: '',
    rating_value: 'Good',
  })

  function handleChange(event) {
    const { name, value } = event.target
    setFormData((prev) => ({ ...prev, [name]: value }))
  }

  function handleSubmit(event) {
    event.preventDefault()
    onCreate(formData)
    setFormData({
      mentorship_id: '',
      rater_user_id: '',
      rated_user_id: '',
      rating_value: 'Good',
    })
  }

  return (
    <form className="form-card" onSubmit={handleSubmit}>
      <h2>Submit Rating</h2>
      <input
        type="text"
        name="mentorship_id"
        placeholder="Mentorship UUID"
        value={formData.mentorship_id}
        onChange={handleChange}
        required
      />
      <input
        type="text"
        name="rater_user_id"
        placeholder="Rater User UUID"
        value={formData.rater_user_id}
        onChange={handleChange}
        required
      />
      <input
        type="text"
        name="rated_user_id"
        placeholder="Rated User UUID"
        value={formData.rated_user_id}
        onChange={handleChange}
        required
      />
      <select name="rating_value" value={formData.rating_value} onChange={handleChange}>
        <option value="Poor">Poor</option>
        <option value="Neutral">Neutral</option>
        <option value="Good">Good</option>
      </select>
      <button type="submit">Submit Rating</button>
    </form>
  )
}
