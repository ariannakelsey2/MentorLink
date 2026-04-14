import { useState } from "react";
import Navbar from "./components/Navbar";
import HomePage from "./pages/HomePage";
import GoalsPage from "./pages/GoalsPage";
import RatingsPage from "./pages/RatingsPage";
import SummaryPage from "./pages/SummaryPage";
import "./App.css";

function App() {
  const [page, setPage] = useState("home");

  return (
    <div>
      <Navbar setPage={setPage} />

      {page === "home" && <HomePage setPage={setPage} />}
      {page === "goals" && <GoalsPage />}
      {page === "ratings" && <RatingsPage />}
      {page === "summary" && <SummaryPage />}
    </div>
  );
}

export default App;