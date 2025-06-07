import { NavLink } from "react-router";
import './header.css'
interface HeaderProps {
  urls: [string, string][];
}

export function Header({ urls }: HeaderProps) {
  return (
    <nav>
      {urls.map(([name, url]) => (
        <NavLink
          key={url}
          to={url}
          className={({ isActive }) => (isActive ? "active" : "")}
        >
          {name}
        </NavLink>
      ))}
    </nav>
  );
}
