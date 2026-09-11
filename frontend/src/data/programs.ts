import type { Program } from "@/lib/types";

// Deterministic Picsum photo — same seed => same photo across renders/sessions.
// Picsum is a random-photo CDN by David Marby; free, no auth, cached globally.
const pic = (seed: string, w = 400, h = 600) =>
  `https://picsum.photos/seed/${encodeURIComponent(seed)}/${w}/${h}`;

export const programs: Program[] = [
  { id: "morning-bulletin", title: "Morning Bulletin", host: "Cherotich Bett", day: "Monday", start: "06:00", end: "09:00", type: "tv", description: "Start your day with the latest headlines from around the world.", image: "/shows/morning.jpeg" },
  { id: "midday-brief", title: "Midday Brief", host: "Kip Chumba", day: "Monday", start: "12:00", end: "13:00", type: "tv", description: "A quick update on stories developing throughout the morning.", image: "/shows/midday.jpg" },
  { id: "prime-time", title: "Prime Time News", host: "Kipchumba Lang'at", day: "Monday", start: "20:00", end: "21:00", type: "tv", description: "The definitive evening news broadcast for the diaspora.", image: "/shows/briefing.jpg" },
  { id: "business-focus", title: "Business Focus", host: "Kipkoech Mutai", day: "Wednesday", start: "19:00", end: "20:00", type: "tv", description: "Deep dives into East African markets, startups and investment.", image: "/shows/business.jpeg" },
  { id: "weekend-culture", title: "Weekend Culture Show", host: "Chebet Kiplagat", day: "Saturday", start: "10:00", end: "12:00", type: "tv", description: "Music, art, and stories from across the Kalenjin community.", image: pic("gotabgaa-weekend-culture") },
  { id: "youth-forum", title: "Youth Forum", host: "Sarah Kimeli", day: "Friday", start: "17:00", end: "18:30", type: "tv", description: "The next generation debates the issues that matter most.", image: pic("gotabgaa-youth-forum") },

  { id: "morning-vibes", title: "Morning Vibes", host: "DJ Kimutai", day: "Monday", start: "06:00", end: "10:00", type: "radio", description: "Wake up to the best of East African and international music.", image: pic("gotabgaa-morning-vibes") },
  { id: "talk-and-music", title: "Talk & Music", host: "Faith Chepkorir", day: "Tuesday", start: "14:00", end: "17:00", type: "radio", description: "Conversation and curated music from around the world.", image: pic("gotabgaa-talk-and-music") },
  { id: "sunday-sanctuary", title: "Sunday Sanctuary", host: "Elder Kiplangat", day: "Sunday", start: "09:00", end: "12:00", type: "radio", description: "Spiritual reflections and inspirational music.", image: pic("gotabgaa-sunday-sanctuary") },
  { id: "night-cruise", title: "Night Cruise", host: "DJ Cherop", day: "Friday", start: "22:00", end: "01:00", type: "radio", description: "Late night mixes to close out your week.", image: pic("gotabgaa-night-cruise") },
];

const DAYS = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"] as const;

function currentDayName(): Program["day"] {
  const d = new Date();
  return DAYS[d.getDay()] as Program["day"];
}

function currentTimeString(): string {
  const d = new Date();
  return `${String(d.getHours()).padStart(2, "0")}:${String(d.getMinutes()).padStart(2, "0")}`;
}

export function getCurrentProgram(type: Program["type"]): Program | undefined {
  const day = currentDayName();
  const now = currentTimeString();
  return programs.find((p) => p.type === type && p.day === day && p.start <= now && p.end >= now);
}

export function getNextProgram(type: Program["type"]): Program | undefined {
  const day = currentDayName();
  const now = currentTimeString();
  return programs
    .filter((p) => p.type === type && p.day === day && p.start > now)
    .sort((a, b) => a.start.localeCompare(b.start))[0];
}

export function getSchedule(type: Program["type"]) {
  return programs.filter((p) => p.type === type);
}
