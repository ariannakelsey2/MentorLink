import { useState } from 'react'

export default function GoalForm({ onCreate }) {
  const [formData, setFormData] = useState({
    mentorship_id: '',
    description: '',
  })

  function handleChange(event) {
    const { name, value } = event.target
    setFormData((prev) => ({ ...prev, [name]: value }))
  }

  function handleSubmit(event) {
    event.preventDefault()
    onCreate(formData)
    setFormData({ mentorship_id: '', description: '' })
  }

  return (
    <form className="form-card" onSubmit={handleSubmit}>
      <h2>Add Goal</h2>
      <input
        type="text"
        name="mentorship_id"
        placeholder="Mentorship UUID"
        value={formData.mentorship_id}
        onChange={handleChange}
        required
      />
      <textarea
        name="description"
        placeholder="Goal description"
        value={formData.description}
        onChange={handleChange}
        required
      />
      <button type="submit">Create Goal</button>
    </form>
  )
}
