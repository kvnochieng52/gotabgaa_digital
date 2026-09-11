export type Category =
  | "News"
  | "Politics"
  | "Sports"
  | "Culture"
  | "Diaspora"
  | "Business"
  | "Opinion";

export interface Article {
  slug: string;
  title: string;
  excerpt: string;
  body: string;
  category: Category;
  author: {
    name: string;
    avatar?: string;
  };
  publishedAt: string; // ISO
  readingTime: number; // minutes
  image: string; // gradient hex pair or URL
  featured?: boolean;
  breaking?: boolean;
  tags?: string[];
}

export interface Program {
  id: string;
  title: string;
  host: string;
  day:
    | "Monday"
    | "Tuesday"
    | "Wednesday"
    | "Thursday"
    | "Friday"
    | "Saturday"
    | "Sunday";
  start: string; // HH:MM
  end: string; // HH:MM
  type: "tv" | "radio";
  description?: string;
  image: string;
}

export interface Video {
  slug: string;
  title: string;
  description: string;
  category: Category;
  duration: string; // e.g. "45:12"
  airedAt: string; // ISO
  image: string;
  views: number;
}

export type ImageSpec = string; // "#E63946|#FF7A1A" — gradient pair for placeholder
