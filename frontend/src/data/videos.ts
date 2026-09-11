import type { Video } from "@/lib/types";

export const videos: Video[] = [
  { slug: "prime-time-weekly-roundup", title: "Prime Time News — Weekly Roundup", description: "The stories that mattered most this week, curated for the diaspora.", category: "News", duration: "1:12:30", airedAt: "2026-08-30T20:00:00Z", image: "#E63946|#FF7A1A", views: 12400 },
  { slug: "kalenjin-sacred-rituals", title: "Kalenjin Cultural Special: Sacred Rituals", description: "An immersive look at initiation ceremonies preserved for generations.", category: "Culture", duration: "48:22", airedAt: "2026-08-28T18:00:00Z", image: "#FFA31A|#FF7A1A", views: 8900 },
  { slug: "east-african-trade-corridor", title: "Business Focus: East African Trade Corridor", description: "How Kenya, Uganda and Tanzania are re-imagining regional commerce.", category: "Business", duration: "32:15", airedAt: "2026-08-27T19:00:00Z", image: "#FF7A1A|#E63946", views: 5100 },
  { slug: "marathon-highlights", title: "Sports Rewind: Marathon Highlights", description: "The best moments from a record-breaking marathon season.", category: "Sports", duration: "24:08", airedAt: "2026-08-26T15:00:00Z", image: "#E63946|#FFA31A", views: 15600 },
  { slug: "diaspora-voices-boston", title: "Diaspora Voices: Boston Community Chat", description: "Boston's Kalenjin community shares stories of migration and belonging.", category: "Diaspora", duration: "58:45", airedAt: "2026-08-25T17:30:00Z", image: "#FFA31A|#E63946", views: 3400 },
  { slug: "late-night-kip-chumba", title: "Late Night Talk with Kip Chumba", description: "Comedy, culture, and conversation to end your day right.", category: "Culture", duration: "1:05:12", airedAt: "2026-08-24T22:30:00Z", image: "#FF7A1A|#FFA31A", views: 9800 },
  { slug: "youth-forum-debate", title: "Youth Forum: Great Diaspora Debate", description: "Next-generation leaders discuss identity, work, and going home.", category: "Diaspora", duration: "44:20", airedAt: "2026-08-23T16:00:00Z", image: "#E63946|#FF7A1A", views: 4200 },
  { slug: "election-analysis-special", title: "Election Analysis Special", description: "A panel of experts break down the latest polling and party moves.", category: "Politics", duration: "1:22:00", airedAt: "2026-08-22T20:00:00Z", image: "#FFA31A|#FF7A1A", views: 21500 },
];

export function getVideoBySlug(slug: string) {
  return videos.find((v) => v.slug === slug);
}
