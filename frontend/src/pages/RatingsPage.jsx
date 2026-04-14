import { useEffect, useState } from "react";
import { getRatings, submitRating } from "../api";

function RatingsPage() {
  const [ratings, setRatings] = useState([]);
  const [error, setError] = useState("");
  const [form, setForm] = useState({
    mentorship_id: "",
    rater_user_id: "",
    rated_user_id: "",
    rating_value: "Good",
  });

  useEffect(() => {
    loadRatings();
  }, []);

  const loadRatings = async () => {
    const data = await getRatings();

    if (Array.isArray(data)) {
      setRatings(data);
      setError("");
    } else {
      setRatings([]);
      setError("Failed to load ratings.");
      console.log("Ratings error:", data);
    }
  };

  const handleSubmit = async () => {
    if (
      !form.mentorship_id ||
      !form.rater_user_id ||
      !form.rated_user_id
    ) return;

    await submitRating(form);

    setForm({
      mentorship_id: "",
      rater_user_id: "",
      rated_user_id: "",
      rating_value: "Good",
    });

    loadRatings();
  };

  return (
    <div className="container">
      <h2>Ratings</h2>

      <div className="card">
        <h3>Submit Rating</h3>

        <input
          placeholder="Mentorship ID"
          value={form.mentorship_id}
          onChange={(e) =>
            setForm({ ...form, mentorship_id: e.target.value })
          }
        />

        <input
          placeholder="Rater User ID"
          value={form.rater_user_id}
          onChange={(e) =>
            setForm({ ...form, rater_user_id: e.target.value })
          }
        />

        <input
          placeholder="Rated User ID"
          value={form.rated_user_id}
          onChange={(e) =>
            setForm({ ...form, rated_user_id: e.target.value })
          }
        />

        <select
          value={form.rating_value}
          onChange={(e) =>
            setForm({ ...form, rating_value: e.target.value })
          }
        >
          <option value="Good">Good</option>
          <option value="Neutral">Neutral</option>
          <option value="Poor">Poor</option>
        </select>

        <button onClick={handleSubmit}>Submit</button>
      </div>

      {error && (
        <div className="card">
          <p>{error}</p>
        </div>
      )}

      {ratings.length > 0 ? (
        ratings.map((r) => (
          <div className="card" key={r.RatingID}>
            <h4>{r.RatingValue}</h4>
            <p>Mentorship: {r.MentorshipID}</p>
            <p>Rater: {r.RaterUserID}</p>
            <p>Rated: {r.RatedUserID}</p>
            <p>Date: {r.RatingDate}</p>
          </div>
        ))
      ) : (
        <div className="card">
          <p>No ratings yet.</p>
        </div>
      )}
    </div>
  );
}

export default RatingsPage;