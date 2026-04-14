const BASE_URL = "http://127.0.0.1:5000/api";

async function safeJson(res) {
  const text = await res.text();
  try {
    return JSON.parse(text);
  } catch {
    return { error: text || "Invalid server response" };
  }
}

export const getGoals = async () => {
  try {
    const res = await fetch(`${BASE_URL}/goals`);
    return await safeJson(res);
  } catch (error) {
    return [];
  }
};

export const createGoal = async (mentorshipId, description) => {
  try {
    const res = await fetch(`${BASE_URL}/goals`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        mentorship_id: mentorshipId,
        description,
      }),
    });
    return await safeJson(res);
  } catch (error) {
    return { error: "Failed to create goal" };
  }
};

export const markGoalAchieved = async (goalId) => {
  try {
    const res = await fetch(`${BASE_URL}/goals/${goalId}/achieve`, {
      method: "PATCH",
    });
    return await safeJson(res);
  } catch (error) {
    return { error: "Failed to mark goal achieved" };
  }
};

export const getRatings = async () => {
  try {
    const res = await fetch(`${BASE_URL}/ratings`);
    return await safeJson(res);
  } catch (error) {
    return [];
  }
};

export const submitRating = async (formData) => {
  try {
    const res = await fetch(`${BASE_URL}/ratings`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        mentorship_id: formData.mentorship_id,
        rater_user_id: formData.rater_user_id,
        rated_user_id: formData.rated_user_id,
        rating_value: formData.rating_value,
      }),
    });
    return await safeJson(res);
  } catch (error) {
    return { error: "Failed to submit rating" };
  }
};

export const getSummary = async (mentorshipId) => {
  try {
    const res = await fetch(`${BASE_URL}/summary/${mentorshipId}`);
    return await safeJson(res);
  } catch (error) {
    return { error: "Failed to load summary" };
  }
};