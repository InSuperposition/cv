import type { Route } from "./+types/_index";
export function meta({}: Route.MetaArgs) {
  return [
    { title: "JavaScript C.V." },
    { name: "description", content: "Curriculum Vitae for Forrest Galloway" },
  ];
}

export default function Home() {
  return <>Home</>;
}
