import { SuiObjectData } from "@mysten/sui/client";
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function getSuiObjectFields<T>(data: SuiObjectData): T | null {
  if (data.content?.dataType !== "moveObject") return null;

  return data.content.fields as T;
}
