"use client";

import { ModeToggle } from "@/components/mode-toggle";
import { Button } from "@/components/ui/Button";
import { cn } from "@/lib/utils";
import { ConnectButton } from "@mysten/dapp-kit";
import Link from "next/link";
import { usePathname } from "next/navigation";

export default function Navbar() {
  const pathname = usePathname();

  return (
    <nav className="bg-zinc-200 dark:bg-zinc-800 p-4 shadow-sm">
      <div className="flex flex-row justify-between items-center">
        <ul className="flex space-x-6">
          <li>
            <Button
              role="button"
              type="button"
              className={cn(pathname === "/" && "bg-blue-400")}
              asChild
            >
              <Link href="/">Home</Link>
            </Button>
          </li>
          <li>
            <Button
              role="button"
              type="button"
              className={cn(pathname === "/wallet" && "bg-blue-400")}
              asChild
            >
              <Link href="/wallet">Wallet</Link>
            </Button>
          </li>
        </ul>
        <div className="inline-flex items-center gap-2">
          <ModeToggle />
          <ConnectButton />
        </div>
      </div>
    </nav>
  );
}
